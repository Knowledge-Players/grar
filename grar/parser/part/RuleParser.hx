package grar.parser.part;

import StringTools;
using StringTools;

class RuleParser{

	var properties: Bool = false;

	public function new(){

	}

	/**
	* Parse the rule string into injunctions
	*
	* @param rule: Rule String
	* @return wether the rule is valid
	*/
	public function parseRule(rule:String, injunction: InjunctionData):Bool
	{
		var state: RuleParserState = IGNORE_SPACES;
		var next: RuleParserState = START_INJUNCTION;

		var start: Int = 0;
		var position: Int = 0;
		var char: Int = rule.fastCodeAt(position);

		var condition = false;

		while(!StringTools.isEof(char)){
			//trace("Current char: "+String.fromCharCode(char)+", entering state: "+state+". Data: "+injunction);
			switch(state){
				case IGNORE_SPACES:
					switch(char){
						case
						'\n'.code,
						'\r'.code,
						'\t'.code,
						' '.code: // nothing

						case '('.code:
							var subInjunction: InjunctionData = cast {keywords: new Array(), variables: new Array()};
							var closeParenthesisIndex = rule.indexOf(")", position)+1;
							if(!Reflect.hasField(injunction, 'subInjunction'))
								injunction.subInjunction = new Array();
							parseRule(rule.substring(++position, closeParenthesisIndex), subInjunction);
							injunction.subInjunction.push(subInjunction);
							position = closeParenthesisIndex;
							injunction.variables.push("$sub"+injunction.subInjunction.length);
							next = START_INJUNCTION;

						default:
							state = next;
							continue;
					}

				case START_INJUNCTION:
					if(isUpperCase(char)){
						start = position;
						state = INJUNCTION;
						next = END_INJUNCTION;
					}
					else
						state = INVALID_RULE;

				case INJUNCTION:
					if(isSpace(char))
						state = next;
					else if(char == ';'.code || char == ')'.code)
						setKeyword(rule, injunction, start, position);
					else if(!isUpperCase(char))
						state = INVALID_RULE;

				case END_INJUNCTION:
					condition = setKeyword(rule, injunction, start, position);
					state = IGNORE_SPACES;
					next = START_VARIABLE;
					continue;

				case START_VARIABLE:
					start = position;
					state = VARIABLE;
					next = END_VARIABLE;

				case VARIABLE:
					if(char == '.'.code){
						if(rule.substr(start, position-start) != "this")
							state = INVALID_RULE;
						else{
							properties = true;
							start = position;
							state = START_VARIABLE;
							next = END_VARIABLE;
						}
					}
					else if(isSpace(char))
						state = END_VARIABLE;
					else if(char == ';'.code || char == ')'.code)
						setVariable(rule, injunction, start, position);

				case END_VARIABLE:
					setVariable(rule, injunction, start, position);
					state = IGNORE_SPACES;

					if(condition)
						next = START_OPERATOR;
					else
						next = START_INJUNCTION;
					continue;

				case START_OPERATOR:
					start = position;
					state = OPERATOR;
					next = END_OPERATOR;

				case OPERATOR:
					if(isSpace(char))
						state = END_OPERATOR;
					else if(!isOperator(char))
						state = INVALID_RULE;

				case END_OPERATOR:
					injunction.operator = rule.substr(start, position-start);
					state = IGNORE_SPACES;
					next = START_VARIABLE;
					continue;

				case INVALID_RULE:
					trace("Rule: "+rule+" is invalid");
					return false;
			}

			// Get next char
			char = rule.fastCodeAt(++position);
		}
		return true;
	}

	///
	// Internals
	//

	private inline function isUpperCase(code:Int):Bool
	{
		return code > 'A'.code && code < 'Z'.code;
	}

	private inline function isSpace(code:Int):Bool
	{
		return (code > 8 && code < 14) || code == ' '.code;
	}

	private inline function isDigit(code: Int): Bool
	{
		return code > '0'.code && code < '9'.code;
	}

	private inline function isOperator(code: Int):Bool
	{
		return code == '='.code || code == '<'.code || code == '>'.code || code == '!'.code;
	}

	private inline function setKeyword(rule: String, injunction: InjunctionData, start: Int, position: Int):Bool
	{
		var keyword = rule.substr(start, position-start).trim();
		injunction.keywords.push(keyword);
		return keyword == "IF";
	}

	private inline function setVariable(rule: String, injunction: InjunctionData, start: Int, position: Int):Void
	{
		var variable = (properties ? "this.":"") + rule.substr(start, position-start).trim();
		injunction.variables.push(variable);
		properties = false;
	}

}

typedef InjunctionData = {
	var keywords: Array<String>;
	var variables: Array<String>;
	var operator: String;
	@:optional var subInjunction: Array<InjunctionData>;
}

private	enum RuleParserState{
	IGNORE_SPACES;
	INVALID_RULE;
	START_INJUNCTION;
	INJUNCTION;
	END_INJUNCTION;
	START_VARIABLE;
	VARIABLE;
	END_VARIABLE;
	START_OPERATOR;
	OPERATOR;
	END_OPERATOR;
}
