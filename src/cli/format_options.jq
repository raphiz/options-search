.[$key] |
   "# \($key)\n\n" +
  "**Description:** \(.description // "No description available.")\n\n" +
  "**Type:** `\(.type // "Unknown type")`\n\n" +
  (if .default then "**Default:** `\(.default.text // "null")`\n\n" else "" end) +
  (if .example then "**Example:** `\(.example.text)`\n\n" else "" end) +
  (if .declarations then "**Declared in:** [\(.declarations[0])](\(.declarations[0]))\n\n" else "" end)
