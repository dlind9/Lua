
--lexit.lua
--program for doing lexical analysis
--Daniel Lind
--CS331
--2/20/2018

--intitialize module
local lexit={}

------------------------------------
--Lexit variables initialized here--
------------------------------------
lexit.KEY=0
lexit.ID=1
lexit.NUMLIT=2
lexit.STRLIT=3
lexit.OP=4
lexit.PUNCT=5
lexit.MAL=6

lexit.catnames = {
    "Keyword",
    "Identifier",
    "NumericLiteral",
	"StringLiteral",
    "Operator",
    "Punctuation",
    "Malformed"
}

----------------------------------------------------------------------
-- isIllegal function-------------------------------------------------
-- Returns true if string c is an illegal character, false otherwise.-

local function isIllegal(c)
    if c:len() ~= 1 then
        return false
    elseif isWhitespace(c) then
        return false
    elseif c >= " " and c <= "~" then
        return false
    else
        return true
	end
end


------------------------------------------------------------------------
-- isWhitespace---------------------------------------------------------
-- Returns true if string c is a whitespace character, false otherwise.-

local function isWhitespace(c)
    if c:len() ~= 1 then
        return false
    elseif c == " " or c == "\t" or c == "\n" or c == "\r"
      or c == "\f" or c == "\v" then
        return true
    else
        return false
    end
end


-------------------------------------------------------------------
-- isDigit---------------------------------------------------------
-- Returns true if string c is a digit character, false otherwise.-

local function isDigit(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "0" and c <= "9" then
        return true
    else
        return false
    end
end


--------------------------------------------------------------------
-- isLetter---------------------------------------------------------
-- Returns true if string c is a letter character, false otherwise.-

local function isLetter(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "A" and c <= "Z" then
        return true
    elseif c >= "a" and c <= "z" then
        return true
    else
		return false
    end
end


---------------------------------------------------------
--lex function, iterates through lexemes in given string-
---------------------------------------------------------
function lexit.lex(program)

--variables located below here
    local pos       -- Index of next character in program
                    -- INVARIANT: when getLexeme is called, pos is
                    --  EITHER the index of the first character of the
                    --  next lexeme OR program:len()+1
    local state     -- Current state for our state machine
    local char        -- Current character
    local lexstr    -- The lexeme, so far
    local category  -- Category of lexeme, set when state set to DONE
    local handlers  -- Dispatch table; value created later
--end variables

--states located below here
    local DONE = 0
    local START = 1
    local LETTER = 2
    local DIGIT = 3
    local PLUS = 5
    local MINUS = 6
    local STAR = 7		--state for %, *, /
	local STRLIT=8
	local EQUALITY=9	--state for equality operators
	local AND=10
	local OR=11
--end states


end

