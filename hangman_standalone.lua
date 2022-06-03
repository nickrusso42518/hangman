-- Our end-user's application uses "echo" to write data, but basic
-- Lua uses io.write, so to avoid extensive find/replace, just make
-- echo behave like io.write in this standalone script
local echo = io.write

-- CLI args specify the word being solved using underscores to represent
-- unknown characters. Also specify the set of already-guessed wrong letters
-- as a contiguous string
local word_in_process = arg[1]
local wrong_letters = arg[2]

-- Some user-defined constants that don't often change are embedded in
-- the script to simplify the CLI arguments
local PER_LINE = 12
local FILENAME = "/Users/nicholasrusso/Desktop/MM/words_short.txt"

-- First, normalize wrong letters by removing any spaces
wrong_letters = string.gsub(wrong_letters, " ", "")

-- To determine already-guessed right letters, iterate over the word in
-- process to extract one of each letter
local right_letters = ""
for i = 1, #word_in_process do
  local char = string.sub(word_in_process, i, i)

  -- If it's not an underscore and not yet recorded as as right letter, add it
  if char ~= "_" and not string.find(right_letters, char) then
    right_letters = right_letters..char
  end
end

-- Underscores should be replaced with a character set that excludes both
-- the already-guessed right and wrong letters. This will narrow down the
-- search criteria and prevent false positives
local blank_replacer = "[^"..right_letters..wrong_letters.."]"

-- The final pattern takes the word in process, replaces underscores with
-- the aforementioned character set, then anchors the string to ensure
-- the word length matches the candidate length
local pattern = "^"..string.gsub(word_in_process, "_", blank_replacer).."$"

-- Quick and dirty way of multi-line comments using a multi-line string.
-- Useful debugging information to ensure core logic variables are correct
local comment_debug = [[
echo("word_in_process: "..word_in_process.."\n")
echo("wrong_letters: "..wrong_letters.."\n")
echo("right_letters: "..right_letters.."\n")
echo("blank_replacer: "..blank_replacer.."\n")
echo("pattern: "..pattern.."\n")
]]

-- Open the word file for reading only, and if it fails, display the
-- error message and quit
local handle, err = io.open(FILENAME, "r")
if not handle then
  echo(error)
  return
end

-- Alternative shorthand syntax for reading in all words from the
-- file as a giant string, then matching contiguous blocks of
-- non-whitespace characters. This returns an iterator with "next" logic
local words_text = handle:read("*all")
local words_iter = words_text:gmatch("%S+")

-- Initialize a counter and start looping over the iterator to display
-- each candidate word
local i = 0
for candidate in words_iter do

  -- Get the first and last indices of any word that matches the pattern
  first, last = string.find(candidate, pattern)
  if first ~= nil and #word_in_process == #candidate then

    -- Match occurred and with proper length; display word and increment i
    echo(candidate)
    i = i + 1

    -- If we reached the line max, print newline, else use comma separation.
    -- Logic collapsed onto one line for brevity, but not required
    if i % PER_LINE == 0 then echo("\n") else echo(", ") end
  end
end
echo("\n\n")
