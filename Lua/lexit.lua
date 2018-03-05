
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
lexit.KEY=1
lexit.ID=2
lexit.NUMLIT=3
lexit.STRLIT=4
lexit.OP=5
lexit.PUNCT=6
lexit.MAL=7

lexit.catnames = {
    "Keyword",
    "Identifier",
    "NumericLiteral",
	"StringLiteral",
    "Operator",
    "Punctuation",
    "Malformed"
}


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
    local pos       				-- Index of next character in program
									-- INVARIANT: when getLexeme is called, pos is
									--  EITHER the index of the first character of the
									--  next lexeme OR program:len()+1
    local state     				-- Current state for our state machine
    local char       				 -- Current character
    local lexstr    				-- The lexeme, so far
    local category  				-- Category of lexeme, set when state set to DONE
    local handlers  				-- Dispatch table; value created later
	local preferOpFlag=false 		--flag for preferOp function
	local secondExpFlag=false		--flag for second exponent
	local insideQuoteFlag=false		--flag for being inside quote
--end variables

--states located below here
	local DONE = 0		--completed
    local START = 1		--completed
    local LETTER = 2	--completed
    local DIGIT = 3		--completed
    local PLUS = 4		--completed
    local MINUS = 5		--completed
    local STAR = 6		--state for %, *, /, ;, [, ] is completed
	local DOUBQUOTE=7	--work needed
	local SINQUOTE=8	--work needed
	local EQUALITY=9	--state for equality operators, completed
	local LOGIC=10		--state for logic || &&, completed
--end states



    -- currChar
    -- Return the current character, at index pos in program. Return
    -- value is a single-character string, or the empty string if pos is
    -- past the end.
    local function currChar()
        return program:sub(pos, pos)
    end

    -- nextChar
    -- Return the next character, at index pos+1 in program. Return
    -- value is a single-character string, or the empty string if pos+1
    -- is past the end.
    local function nextChar()
        return program:sub(pos+1, pos+1)
    end

	-- prevChar
    -- Return the previous character, at index pos-1 in program. Return
    -- value is a single-character string.
    local function prevChar()
        return program:sub(pos-1, pos-1)
    end

    -- nextNextChar
    -- Return the 2nd next character, at index pos+1 in program. Return
    -- value is a single-character string, or the empty string if pos+1
    -- is past the end.
    local function nextNextChar()
        return program:sub(pos+2, pos+2)
    end

    -- drop1
    -- Move pos to the next character.
    local function drop1()

        pos = pos+1
    end

    -- add1
    -- Add the current character to the lexeme, moving pos to the next
    -- character.
    local function add1()
        lexstr = lexstr .. currChar()
        drop1()
    end

	local function secondExponent()
		return secondExpFlag
	end

	local function insideQuote()
		return innerQuoteFlag
	end
	--preferOp
	--sets flag to true if operator
	function lexit.preferOp()
		preferOpFlag=true
	end

    -- skipWhitespace
    -- Skip whitespace and comments, moving pos to the beginning of
    -- the next lexeme, or to program:len()+1.
    local function skipWhitespace()
        while true do
            while isWhitespace(currChar()) do
                drop1()
            end
            if currChar() ~= "#" then  -- Comment?
                break
            end
            drop1()
            while true do
                if currChar() == "\n"then
                    drop1()
                    break
				elseif currChar() == "" then
					return
				else
					drop1()
				end
            end
        end
    end


    local function handle_START()
        if isIllegal(ch) then
            add1()
            state = DONE
            category = lexit.MAL
        elseif isLetter(ch) or ch == "_" then
            add1()
            state = LETTER
		elseif ch == "\"" then
			add1()
			state=DOUBQUOTE
		elseif ch == "'" then
			add1()
			state=SINQUOTE
        elseif isDigit(ch) then
            add1()
            state = DIGIT
        elseif ch == "+" then
            add1()
            state = PLUS
        elseif ch == "-" then
            add1()
            state = MINUS
        elseif ch == "*" or ch == "/" or ch == "%"
		or ch == ";" or ch == "[" or ch == "]" then
            add1()
            state = STAR
        elseif ch == "!" or ch == "<" or ch ==">" or ch == "=" then
			add1()
			state = EQUALITY
		elseif ch == "&" or ch == "|" then
			add1()
			state = LOGIC
        else
            add1()
            state = DONE
            category = lexit.PUNCT
        end
    end

	local function handle_LETTER()
		if isLetter(ch) or isDigit(ch) or ch == "_" then
			add1()
		else
			state = DONE
            if lexstr == "call" or
			   lexstr == "end" or
			   lexstr == "print" or
			   lexstr == "cr" or
			   lexstr == "else" or
			   lexstr == "elseif" or
			   lexstr == "false" or
			   lexstr == "func" or
			   lexstr == "if" or
			   lexstr == "input" or
			   lexstr == "print" or
			   lexstr == "true" or
			   lexstr == "while"
			   then
                category = lexit.KEY
            else
				lexit.preferOp()
                category = lexit.ID
            end
        end
    end

	local function hasSecondQuotation(ch)
		if nextChar() == "" then
			return
		elseif ch == "\"" then
		add1()
			while ch ~= "\"" do

			end
		end
	end

	local function handle_SINQUOTE()
		if insideQuote() == true then
			if ch ~= "'" then
				add1()
				state = SINQUOTE
				category = lexit.STRLIT
			elseif ch == "'" then
				insideQuoteFlag=false	--has exited inner quote
				add1()
				state = DOUBQUOTE
			end
		elseif ch == "'" then
			add1()
			state = DONE
			category = lexit.STRLIT
			return
		elseif ch == "\"" and prevChar() == "'" then
			insideQuoteFlag=true
			add1()
			state = DOUBQUOTE
		elseif ch == "\"" then
			add1()
			state = SINQUOTE
			category = lexit.STRLIT
		elseif ch == "\n" or ch == "" then
			add1()
			state = DONE
			category = lexit.MAL
		else
			add1()
			state = SINQUOTE
			category = lexit.STRLIT
		end
	end

	local function handle_DOUBQUOTE()
		if insideQuote() == true then
			if ch ~= "\"" then
				add1()
				state = SINQUOTE
				category = lexit.STRLIT
			elseif ch == "\"" then
				insideQuoteFlag=false	--has exited inner quote
				add1()
				state = DOUBQUOTE
			end
		elseif ch == "\"" then
			add1()
			state = DONE
			category = lexit.STRLIT
			return
		elseif ch == "'" and prevChar() == "\"" then
			insideQuoteFlag=true
			add1()
			state = SINQUOTE
		elseif ch == "\n" or ch == "" then
			add1()
			state = DONE
			category = lexit.MAL
		else
			add1()
			state = DOUBQUOTE
			category = lexit.STRLIT
		end
	end

    local function handle_DIGIT()
	lexit.preferOp()
        if isDigit(ch) then
            add1()
		elseif ch == "e" or ch == "E" then
			if (secondExponent() or
			   nextChar() <= "0" or nextChar() >= "9") and nextChar() ~= "+" then
					state = DONE
					category = lexit.NUMLIT
			elseif nextChar() == "+" then
				secondExpFlag=true
				if nextNextChar() <= "0" or nextNextChar() >= "9" then
					state = DONE
					category = lexit.NUMLIT
					return
				end
				add1()
				add1()
			else
				secondExpFlag=true
				add1()
			end
        else
            state = DONE
            category = lexit.NUMLIT
        end
    end



    local function handle_PLUS()
		if preferOpFlag == true then
			state = DONE
			category = lexit.OP
        elseif isDigit(ch) then
			add1()
            state = DIGIT
        else
            state = DONE
            category = lexit.OP
        end
    end

    local function handle_MINUS()
		if preferOpFlag == true then
			state = DONE
			category = lexit.OP
        elseif isDigit(ch) then
            add1()
            state = DIGIT
        else
            state = DONE
            category = lexit.OP
        end
    end



    local function handle_STAR()  -- Handles *, /, ;, [, ], %
            state = DONE
            category = lexit.OP
    end

	local function handle_EQUALITY()
		if ch == "=" then
			add1()
			state = DONE
			category = lexit.OP
		else
			state = DONE
			category = lexit.OP
		end
	end

	local function handle_LOGIC()
		if prevChar() == "&" then
			if ch == "&" then
				add1()
				state = DONE
				category =lexit.OP
			else
				state = DONE
				category = lexit.PUNCT
			end
		elseif prevChar() == "|" then
			if ch == "|" then
				add1()
				state = DONE
				category =lexit.OP
			else
				state = DONE
				category = lexit.PUNCT
			end
		else
			state = DONE
			category = lexit.PUNCT
		end
	end

	--state handler functions table
	    handlers = {
        [DONE]=handle_DONE,
        [START]=handle_START,
        [LETTER]=handle_LETTER,
        [DIGIT]=handle_DIGIT,
        [PLUS]=handle_PLUS,
        [MINUS]=handle_MINUS,
        [STAR]=handle_STAR,
		[DOUBQUOTE]=handle_DOUBQUOTE,
		[SINQUOTE]=handle_SINQUOTE,
		[EQUALITY]=handle_EQUALITY,
		[LOGIC]=handle_LOGIC,
    }


	    -- getLexeme
    -- Called each time through the for-in loop.
    -- Returns a pair: lexeme-string (string) and category (int), or
    -- nil, nil if no more lexemes.
    local function getLexeme(dummy1, dummy2)
        if pos > program:len() then
			preferOpFlag=false
            return nil, nil
        end
        lexstr = ""
        state = START
        while state ~= DONE do
            ch = currChar()
            handlers[state]()
        end
        skipWhitespace()
		preferOpFlag=false
        return lexstr, category
    end



    -- Initialize & return the iterator function
    pos = 1
    skipWhitespace()
	preferOpFlag=false
    return getLexeme, nil, nil




end	--end for lexit.lex

return lexit

