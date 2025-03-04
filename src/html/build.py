import sys
import json
import markdown_it
import html
from jinja2 import Environment, FileSystemLoader

# Source: https://github.com/NixOS/nixpkgs/blob/4ba9c235651b71d9bf249329318e5e04d65a39b4/pkgs/tools/nix/nixos-render-docs/src/nixos_render_docs/md.py#L581
md = markdown_it.MarkdownIt(
            "commonmark",
            {
                'maxNesting': 100,
                'html': False,
                'typographer': True,
            },
        )

# Source: https://github.com/NixOS/nixpkgs/blob/4ba9c235651b71d9bf249329318e5e04d65a39b4/pkgs/tools/nix/nixos-render-docs/src/nixos_render_docs/options.py#L26
def option_is(option, key: str, typ: str):
    if key not in option:
        return None
    if type(option[key]) != dict:
        return None
    if option[key].get('_type') != typ: # type: ignore[union-attr]
        return None
    return option[key] # type: ignore[return-value]


def render_code(option, key):
    if lit := option_is(option, key, 'literalMD'):
        return lit['text']
    elif lit := option_is(option, key, 'literalExpression'):
        return lit['text']
    elif key in option:
        raise Exception(f"{key} has unrecognized type", option[key])

def escape(text):
    if text is None:
        return ''
    else:
        return html.escape(text)

def main():
    source = sys.argv[1]
    template = sys.argv[2]
    doc_title = sys.argv[3]
    destination = sys.argv[4]
    
    with (
        open(source) as sourceFile, 
        open(template) as templateFile,
        open(destination,mode="w") as destinationFile,
    ):
        options = []
        for title, option in json.load(sourceFile).items():
            optionEntry = {"title": title}
            if desc := option.get('description'):
                optionEntry["description"] = md.render(desc)
            if typ := option.get('type'):
                ro = " *(read only)*" if option.get('readOnly', False) else ""
                optionEntry["type"] = f"{typ}{ro}"
            if option.get('default'):
                optionEntry["default"] = render_code(option, 'default')
            if option.get('example'):
                optionEntry["example"] = render_code(option, 'example')
            if decl := option.get('declarations'):
                optionEntry["declared_by"] = f"{decl}" # TODO: format, replace whatever
            options.append(optionEntry)

        environment = Environment()
        environment.filters['escape'] = escape
        template = environment.from_string(templateFile.read())
        rendered = template.render({"options": options, "title": doc_title})
        print(rendered)
        destinationFile.write(rendered)

main()