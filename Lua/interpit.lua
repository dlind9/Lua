-- interpit.lua  INCOMPLETE
-- Daniel Lind
-- 04/12/2018
--
-- For CS F331 / CSCE A331 Spring 2018
-- Interpret AST from parseit.parse
-- For Assignment 6, Exercise B


-- *******************************************************************
-- * To run a Dugong program, use dugong.lua (which uses this file). *
-- *******************************************************************


local interpit = {}  -- Our module


-- ***** Variables *****


-- Symbolic Constants for AST

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


-- ***** Utility Functions *****


-- numToInt
-- Given a number, return the number rounded toward zero.
local function numToInt(n)
    assert(type(n) == "number")

    if n >= 0 then
        return math.floor(n)
    else
        return math.ceil(n)
    end
end


-- strToNum
-- Given a string, attempt to interpret it as an integer. If this
-- succeeds, return the integer. Otherwise, return 0.
local function strToNum(s)
    assert(type(s) == "string")

    -- Try to do string -> number conversion; make protected call
    -- (pcall), so we can handle errors.
    local success, value = pcall(function() return 0+s end)

    -- Return integer value, or 0 on error.
    if success then
        return numToInt(value)
    else
        return 0
    end
end


-- numToStr
-- Given a number, return its string form.
local function numToStr(n)
    assert(type(n) == "number")

    return ""..n
end


-- boolToInt
-- Given a boolean, return 1 if it is true, 0 if it is false.
local function boolToInt(b)
    assert(type(b) == "boolean")

    if b then
        return 1
    else
        return 0
    end
end

-- checkDefined
-- given element from state, if nil return 0, otherwise return defined
local function checkDefined(defined)
	if defined then
		return defined
	else
		return 0
	end
end


-- astToStr
-- Given an AST, produce a string holding the AST in (roughly) Lua form,
-- with numbers replaced by names of symbolic constants used in parseit.
-- A table is assumed to represent an array.
-- See the Assignment 4 description for the AST Specification.
--
-- THIS FUNCTION IS INTENDED FOR USE IN DEBUGGING ONLY!
-- IT SHOULD NOT BE CALLED IN THE FINAL VERSION OF THE CODE.
function astToStr(x)
    local symbolNames = {
        "STMT_LIST", "INPUT_STMT", "PRINT_STMT", "FUNC_STMT",
        "CALL_FUNC", "IF_STMT", "WHILE_STMT", "ASSN_STMT", "CR_OUT",
        "STRLIT_OUT", "BIN_OP", "UN_OP", "NUMLIT_VAL", "BOOLLIT_VAL",
        "SIMPLE_VAR", "ARRAY_VAR"
    }
    if type(x) == "number" then
        local name = symbolNames[x]
        if name == nil then
            return "<Unknown numerical constant: "..x..">"
        else
            return name
        end
    elseif type(x) == "string" then
        return '"'..x..'"'
    elseif type(x) == "boolean" then
        if x then
            return "true"
        else
            return "false"
        end
    elseif type(x) == "table" then
        local first = true
        local result = "{"
        for k = 1, #x do
            if not first then
                result = result .. ","
            end
            result = result .. astToStr(x[k])
            first = false
        end
        result = result .. "}"
        return result
    elseif type(x) == "nil" then
        return "nil"
    else
        return "<"..type(x)..">"
    end
end


-- ***** Primary Function for Client Code *****


-- interp
-- Interpreter, given AST returned by parseit.parse.
-- Parameters:
--   ast     - AST constructed by parseit.parse
--   state   - Table holding Dugong variables & functions
--             - AST for function xyz is in state.f["xyz"]
--             - Value of simple variable xyz is in state.v["xyz"]
--             - Value of array item xyz[42] is in state.a["xyz"][42]
--   incall  - Function to call for line input
--             - incall() inputs line, returns string with no newline
--   outcall - Function to call for string output
--             - outcall(str) outputs str with no added newline
--             - To print a newline, do outcall("\n")
-- Return Value:
--   state, updated with changed variable values
function interpit.interp(ast, state, incall, outcall)
    -- Each local interpretation function is given the AST for the
    -- portion of the code it is interpreting. The function-wide
    -- versions of state, incall, and outcall may be used. The
    -- function-wide version of state may be modified as appropriate.


    function interp_stmt_list(ast)
        for i = 2, #ast do
            interp_stmt(ast[i])
        end
    end

	--could rewrite as just one function and pass in
	--ast[2] or ast[3] for lhside or rhside
	function interp_lhside(ast)
		if ast[2][1] == NUMLIT_VAL then
			lh_num = strToNum(ast[2][2])
		elseif ast[2][1] == BOOLLIT_VAL then
			if ast[2][2] == "true" then
				lh_num = 1
			else
				lh_num = 0
			end
		elseif ast[2][1] == SIMPLE_VAR then
			key = ast[2][2]
			lh_num=checkDefined(state.v[key])
		elseif ast[2][1] == ARRAY_VAR then
			eval = interp_exp(ast[2][3]) --expression ast is in 3rd element of ast
			key = ast[2][2]
			if state.a[key] then
				lh_num = checkDefined(state.a[key][eval])
			else
				lh_num = 0
			end
		elseif ast[2] then
			lh_num = interp_exp(ast[2])
		end
		return lh_num
	end

	function interp_rhside(ast)
		if ast[3][1] == NUMLIT_VAL then
			rh_num = strToNum(ast[3][2])
		elseif ast[3][1] == BOOLLIT_VAL then
			if ast[3][2] == "true" then
				rh_num = 1
			else
				rh_num = 0
			end
		elseif ast[3][1] == SIMPLE_VAR then
			key = ast[3][2]
			rh_num=checkDefined(state.v[key])
		elseif ast[3][1] == ARRAY_VAR then
			eval = interp_exp(ast[3][3]) --expression ast is in 3rd element of ast
			key = ast[3][2]
			if state.a[key] then
				rh_num = checkDefined(state.a[key][eval])
			else
				rh_num = 0
			end
		elseif ast[3] then
			rh_num = interp_exp(ast[3])
		end
		return rh_num
	end

	function interp_bin_op(op, lhside, rhside)
		if op == "+" then
			return numToInt(lhside+rhside)
		elseif op == "-" then
			return numToInt(lhside-rhside)
		elseif op == "*" then
			return numToInt(lhside*rhside)
		elseif op == "/" then
			if rhside == 0 then
				return 0
			else
				return numToInt(lhside/rhside)
			end
		elseif op == "%" then
			if rhside == 0 then
				return 0
			else
				return numToInt(lhside%rhside)
			end
		elseif op == "==" then
			return boolToInt(lhside==rhside)
		elseif op == "!=" then
			return boolToInt(lhside~=rhside)
		elseif op == "<" then
			return boolToInt(lhside<rhside)
		elseif op == "<=" then
			return boolToInt(lhside<=rhside)
		elseif op == ">" then
			return boolToInt(lhside>rhside)
		elseif op == ">=" then
			return boolToInt(lhside>=rhside)
		elseif op == "&&" then
			if lhside ~= 0 and rhside ~= 0 then
				return boolToInt(true)
			else
				return boolToInt(false)
			end
		elseif op == "||" then
			if lhside == 0 and rhside == 0 then
				return boolToInt(false)
			else
				return boolToInt(true)
			end
		else
			return -9000		--just pretend this isn't here
		end
	end

	function interp_exp(ast)
		local key, eval, saveop, lhside, rhside
		if (ast[1] == NUMLIT_VAL) then
			return strToNum(ast[2])
		elseif ast[1] == SIMPLE_VAR then
			key = ast[2]
			return checkDefined(state.v[key])
		elseif ast[1] == ARRAY_VAR then
			key = ast[2]
			eval = interp_exp(ast[3])
			if state.a[key] then	--checks to see if the element of key is nil
				return checkDefined(state.a[key][eval])
			else
				return 0
			end
		elseif ast[1] == BOOLLIT_VAL then
			if ast[2] == "true" then
				return 1
			else
				return 0
			end
		elseif ast[1] == CALL_FUNC then
			print(key)
			key = ast[2]
			body = state.f[key]
			if body == nil then
				body = {STMT_LIST}
				print("BODY IS NILL")
			end
			print(key)
			interp_stmt_list(body)
			print(state.v["return"])
			print(state.v["a"])
			return checkDefined(state.v["return"])
		elseif ast[1][1] == UN_OP then
			saveop = ast[1][2]
			eval = interp_exp(ast[2])
			if saveop == "!" then
				if eval == 0 then
					return 1
				else
					return 0
				end
			elseif saveop == "+" then
				if eval<0 then
					return eval*-1
				else
					return eval
				end
			elseif saveop == "-" then
				return eval*-1
			end
		elseif ast[1][1] == BIN_OP then
			saveop = ast[1][2]
			lhside = interp_lhside(ast)
			rhside = interp_rhside(ast)
			return interp_bin_op(saveop, lhside, rhside)
		end
	end

    function interp_stmt(ast)
        local name, body, str

        if ast[1] == INPUT_STMT then
            numstr = incall()
			if ast[2][1] == SIMPLE_VAR then
				key = ast[2][2]
				state.v[key] = strToNum(numstr)
			end
        elseif ast[1] == PRINT_STMT then
            for i = 2, #ast do
                if ast[i][1] == CR_OUT then
                    outcall("\n")
                elseif ast[i][1] == STRLIT_OUT then
                    str = ast[i][2]
                    outcall(str:sub(2,str:len()-1))  -- Remove quotes
                else
					eval = interp_exp(ast[i])
                    outcall(numToStr(eval))
                end
            end
        elseif ast[1] == FUNC_STMT then
            name = ast[2]
            body = ast[3]
            state.f[name] = body
        elseif ast[1] == CALL_FUNC then
            name = ast[2]
            body = state.f[name]
            if body == nil then
                body = { STMT_LIST }  -- Default AST
            end
            interp_stmt_list(body)
        elseif ast[1] == IF_STMT then
            if interp_exp(ast[2]) ~= 0 then
				if ast[3][2] then
					interp_stmt_list(ast[3])
					--print("OUTCALL")
				end
				return
			end
			for i = 4, #ast do
				if ast[4] then		--check for 4th elemnt
					if ast[i][1] == STMT_LIST then	-- if stmt_list then it is an else
						if ast[i][2] then
							interp_stmt_list(ast[i])	--then interp_stmt the current element
							print("OUTCALL")
						end
						return
					else		--else it's an elseif
						if interp_exp(ast[i]) ~= 0 then		--if expression in ast is nonzero
							if ast[i+1][2] then
								interp_stmt_list(ast[i+1])			--interp_stmt the next elemnt
								--print("OUTCALL")
							end
							return
						end
					end
				else 				--if no 4th element then do nothing
					return
				end
			end
        elseif ast[1] == WHILE_STMT then
            while interp_exp(ast[2]) ~= 0 do
					interp_stmt_list(ast[3])
			end
        else
            assert(ast[1] == ASSN_STMT)
            key = ast[2][2]
			assn = interp_exp(ast[3])
			if ast[2][1] == SIMPLE_VAR then
				state.v[key] = assn
			else	--else its an array variable
				idx = interp_exp(ast[2][3])
				print(idx)
				print(key)
				print(assn)
				if type(state.a[key]) ~= type({}) then		--checks to see if element is a table
					state.a[key] = {}						--if not it is set to empty table
				end
				state.a[key][idx]=assn
			end
        end
    end


    -- Body of function interp
    interp_stmt_list(ast)
    return state
end


-- ***** Module Export *****


return interpit

