--parseit.lua
--Program for parsing the lexer written in previous assignment
--Daniel Lind
--CS 331, Assignment 4


--import lexit.lua
lexit=require "lexit"

--Initialization of module
local parseit={}


-------------
-- Variables-
-------------

-- For lexer iteration
local iter          -- Iterator returned by lexer.lex
local state         -- State for above iterator (maybe not used)
local lexer_out_s   -- Return value #1 from above iterator
local lexer_out_c   -- Return value #2 from above iterator

-- For current lexeme
local lexstr = ""   -- String form of current lexeme
local lexcat = 0    -- Category of current lexeme:
                    --  one of categories below, or 0 for past the end

--end of variables


-----------------------------------------------
-- Symbolic Constants for AST initialized here-
-----------------------------------------------
local STMT_LIST   = 1
local INPUT_STMT  = 2
local PRINT_STMT  = 3
local FUNC_STMT   = 4
local CALL_FUNC   = 5
local IF_STMT     = 6
local WHILE_STMT  = 7
local ASSN_STMT   = 8
local CR_OUT      = 9
local STRLIT_OUT  = 10
local BIN_OP      = 11
local UN_OP       = 12
local NUMLIT_VAL  = 13
local BOOLLIT_VAL = 14
local SIMPLE_VAR  = 15
local ARRAY_VAR   = 16
-- end of AST constants



-- advance
-- Go to next lexeme and load it into lexstr, lexcat.
-- Should be called once before any parsing is done.
-- Function init must be called before this function is called.
local function advance()
    -- Advance the iterator
    lexer_out_s, lexer_out_c = iter(state, lexer_out_s)

    -- If we're not past the end, copy current lexeme into vars
    if lexer_out_s ~= nil then
        lexstr, lexcat = lexer_out_s, lexer_out_c
    else
        lexstr, lexcat = "", 0
    end
	if lexstr == "]" or lexstr == ")" or
						lexstr == "true" or
						lexstr == "false" or
						lexcat == lexit.ID or
						lexcat == lexit.NUMLIT then
		lexit.preferOp()
	end
end


-- init
-- Initial call. Sets input for parsing functions.
local function init(prog)
    iter, state, lexer_out_s = lexit.lex(prog)
    advance()
end

-- atEnd
-- Return true if pos has reached end of input.
-- Function init must be called before this function is called.
local function atEnd()
    return lexcat == 0
end



-- matchString
-- Given string, see if current lexeme string form is equal to it. If
-- so, then advance to next lexeme & return true. If not, then do not
-- advance, return false.
-- Function init must be called before this function is called.
local function matchString(s)
    if lexstr == s then
        advance()
        return true
    else
        return false
    end
end



-- matchCat
-- Given lexeme category (integer), see if current lexeme category is
-- equal to it. If so, then advance to next lexeme & return true. If
-- not, then do not advance, return false.
-- Function init must be called before this function is called.
local function matchCat(c)
    if lexcat == c then
        advance()
        return true
    else
        return false
    end
end



-- parse_program
-- Parsing function for nonterminal "program".
-- Function init must be called before this function is called.
function parse_program()
    local good, ast
    good, ast = parse_stmt_list()
    return good, ast
end


-- parse_stmt_list
-- Parsing function for nonterminal "stmt_list".
-- Function init must be called before this function is called.
function parse_stmt_list()
    local good, ast, newast
    ast = { STMT_LIST }
    while true do
        if lexstr ~= "input"
          and lexstr ~= "print"
          and lexstr ~= "func"
          and lexstr ~= "call"
          and lexstr ~= "if"
          and lexstr ~= "while"
          and lexcat ~= lexit.ID then
            return true, ast
        end
        good, newast = parse_statement()
        if not good then
            return false, nil
        end
        table.insert(ast, newast)
    end
end


-- parse_statement
-- Parsing function for nonterminal "statement"
-- Function init must be called before this function is called.
function parse_statement()
    local good, ast1, ast2, savelex
	savelex = lexstr
    if matchString("input") then
		savelex=lexstr
        good, ast1 = parse_lvalue()
        if not good then
            return false, nil
        end
        return true, { INPUT_STMT, ast1 }

    elseif matchString("print") then
        good, ast1 = parse_print_arg()
        if not good then
            return false, nil
        end
        ast2 = { PRINT_STMT, ast1 }
        while true do
            if not matchString(";") then
                break
            end
            good, ast1 = parse_print_arg()
            if not good then
                return false, nil
            end
            table.insert(ast2, ast1)
        end
        return true, ast2

    elseif matchString("func") then
		savelex=lexstr
		if matchCat(lexit.ID) then
			ast1={FUNC_STMT, savelex}
			good, ast2 = parse_stmt_list()
			if not good then
				return false, nil
			end
			if not matchString("end") then
				return false, nil
			end
			table.insert(ast1, ast2)
			return true, ast1
		end

	elseif matchString("call") then
		savelex=lexstr
		if matchCat(lexit.ID) then
			return true, {CALL_FUNC, savelex}
		end


	elseif matchString("if") then
		local newast
		ast1 = {IF_STMT}
		good, ast2 = parse_expr()
		if not good then
			return false, nil
		end
		table.insert(ast1, ast2)
		good, ast2 = parse_stmt_list()
		if not good then
			return false, nil
		end
		table.insert(ast1, ast2)
		while true do
			if matchString("end") then
				break
			elseif matchString("else") then
				good,ast2 = parse_stmt_list()
				if not good then
					return false, nil
				end
				table.insert(ast1, ast2)
				if matchString("end") then
					break
				end
			elseif matchString("elseif") then
				good, ast2 = parse_expr()
				if not good then
					return false, nil
				end
				table.insert(ast1,ast2)
				good, ast2 = parse_stmt_list()
				if not good then
					return false, nil
				end
				table.insert(ast1, ast2)
			else
				return false, nil
			end
		end
		return true, ast1

	elseif matchString("while") then
		good, ast1 = parse_expr()
		if not good then
			return false, nil
		end
		good, ast2 = parse_stmt_list()
		if not good then
			return false, nil
		end
		if not matchString("end") then
			return false, nil
		end
		return true, {WHILE_STMT, ast1, ast2}

	else
		good, ast1 = parse_lvalue()
		if not good then
			return false, nil
		end
		if matchString("=") then
			good, ast2 = parse_expr()
			if not good then
				return false, nil
			end
			return true, {ASSN_STMT, ast1, ast2}
		end
	end
end


--parse_print_arg
--parsing function for the argument of a print statement
function parse_print_arg()												--finished, probably needs work for passing tests
	local good, ast1, ast2, savelex
	savelex=lexstr
	if matchString("cr") then
		return true, { CR_OUT }
	elseif matchCat(lexit.STRLIT) then
		ast1 = {STRLIT_OUT, savelex}
		return true, ast1
	else
		return parse_expr()
	end
end


-- parse_expr
-- Parsing function for nonterminal "expr".
-- Function init must be called before this function is called.
function parse_expr()
    local good, ast, saveop, newast
    good, ast = parse_comp_expr()
    if not good then
        return false, nil
    end
    while true do
        saveop = lexstr
        if not matchString("&&") and not matchString("||") then
            break
        end
        good, newast = parse_comp_expr()
        if not good then
            return false, nil
        end
        ast = { { BIN_OP, saveop }, ast, newast }
    end
    return true, ast
end


--parse_comp_expr
--parsing function for nonterminal "comp_expr"
function parse_comp_expr()
	local good, ast, saveop, newast
	if matchString("!") then
		good, ast = parse_comp_expr()
		if not good then
			return false, nil
		end
		return true, {{UN_OP, "!"}, ast}
	else
	good, ast = parse_arith_expr()
	if not good then
		return false, nil
	end
		while true do
			saveop = lexstr

			if not matchString("==") and not matchString("!=")
			and not matchString("<") and not matchString("<=")
			and not matchString(">") and not matchString(">=") then
				break
			end
			good, newast = parse_arith_expr()
			if not good then
				return false, nil
			end
			ast ={ { BIN_OP, saveop }, ast, newast}
		end
	end
	return true, ast
end


--parse_arit_expr
--parsing function for nonterminal "arith_expr"
function parse_arith_expr()
    local good, ast, saveop, newast
    good, ast = parse_term()
    if not good then
        return false, nil
    end

    while true do
        saveop = lexstr
        if not matchString("+") and not matchString("-") then
            break
        end
        good, newast = parse_term()
        if not good then
            return false, nil
        end
        ast = { { BIN_OP, saveop }, ast, newast }
    end
    return true, ast
end



-- parse_term
-- Parsing function for nonterminal "term".
-- Function init must be called before this function is called.
function parse_term()
    local good, ast, saveop, newast
    good, ast = parse_factor()
    if not good then
        return false, nil
    end

    while true do
        saveop = lexstr
        if not matchString("*") and not matchString("/")
		and not matchString("%") then
            break
        end
        good, newast = parse_factor()
        if not good then
            return false, nil
        end
        ast = { { BIN_OP, saveop }, ast, newast }
    end
    return true, ast
end


-- parse_factor
-- Parsing function for nonterminal "factor".
function parse_factor()
	local savelex, good, ast
	savelex = lexstr
	if matchString("(") then
		good, ast = parse_expr()
        if not good then
            return false, nil
        end
        if not matchString(")") then
            return false, nil
        end
        return true, ast
	elseif matchString("+") or matchString("-") then
		good, ast = parse_factor()
		if not good then
			return false, nil
		end
		return true, {{ UN_OP, savelex }, ast}
	elseif matchString("call") then
		savelex=lexstr
		if matchCat(lexit.ID) then
			return true, {CALL_FUNC, savelex}
		end
	elseif matchCat(lexit.NUMLIT) then
		return true, { NUMLIT_VAL, savelex }
	elseif matchString("true") then
		return true, {BOOLLIT_VAL, "true"}
	elseif matchString("false") then
		return true, {BOOLLIT_VAL, "false"}
	elseif lexcat == lexit.ID then
		good, ast = parse_lvalue()
		if not good then
			return false, nil
		end
		return true, ast
	else
		return false, nil
	end
end


--parse_lvalue
--parsing function for the nonterminal "lvalue"
--takes an argument of the previous lexstr which
--is the name of the VAR
function parse_lvalue()
	local good, ast, savelex
	savelex = lexstr
	if matchCat(lexit.ID) then
		if matchString("[") then
			good, ast = parse_expr()
			if not good then
				return false, nil
			end
			if not matchString("]") then
				return false, nil
			end
			return true, {ARRAY_VAR, savelex, ast}
		end
		return true, {SIMPLE_VAR, savelex}
	end
end


--parsing function below


function parseit.parse(prog)
    -- Initialization
    init(prog)

    -- Get results from parsing
    local good, ast = parse_program()  -- Parse start symbol
    local done = atEnd()

    -- And return them
    return good, done, ast

end

return parseit
