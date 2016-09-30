invalid_letters = {
// This function is necessary becaus copytoclipboard and copyfromclippboard can only work with ASCII charracters.
// This function change the german special letters like "ü" to "ue"
// Input must be string 
	private ["_input","_old_special_characters","_new_special_characters","_old_letters","_new_letters","_output","_hit","_x","_this"];
	
	_input = toArray (str _this);
	_old_special_characters = [];
	_new_special_characters = [];
	_old_letters = ["Ä","ä","Ö","ö","Ü","ü","ß"];
	_new_letters = ["Ae","ae","Oe","oe","Ue","ue","ss"];
	_output = [];
	
	{
		_old_special_characters append toArray _x;
		
	}forEach _old_letters;
	
	{
		_new_special_characters pushback toArray _x;
	}forEach _new_letters;
		
	_old_special_characters append [160]; // change of non-break space to normal space
	_new_special_characters append [32];
	
	{
		_hit = _old_special_characters find _x;
		
			if (_hit > -1) then {
				if (typeName (_new_special_characters select _hit) == "Array" )then {
					_output  append (_new_special_characters select _hit); 	
					
				} else
				{
					_output  pushBack (_new_special_characters select _hit);
				};
			} else
			{
			_output pushBack _x;
			};
	}forEach _input;
	
	

	_output = toString _output;
	_output;
};

modsinstalled = {
private ["_result","_myarray0","_myarray1","_myarray2","_myarray3"];
// check addons
// this should check if any other addons than the ones from BI are loaded.
_result = false;
_myarray0 = [];
_myarray1 = [];
_myarray2 = [];
_myarray3 = [];


{if (! (["a3_", _x] call BIS_fnc_inString)) then {_myarray0 pushBack _x}} forEach activatedAddons;
{if (! (["curatoronly_", _x] call BIS_fnc_inString)) then {_myarray1 pushBack _x}} forEach _myarray0;
{if (! (["map_vr", _x] call BIS_fnc_inString)) then {_myarray2 pushBack _x}} forEach _myarray1;
{if (! (["map_vr", _x] call BIS_fnc_inString)) then {_myarray2 pushBack _x}} forEach _myarray1;
{if (! (["3den", _x] call BIS_fnc_inString)) then {_myarray3 pushBack _x}} forEach _myarray2;


if (count _myarray3 > 0) then {_result = true} else {_result = false};

_result;
};

ModKeys = {
	// This function checks all keys for Mods in the profileNamespace
	private  ["_br","_tab","_myMods","_myResult","_myActualMod","_myModsComand","_mycomando","_modName","_actionName","_displayName","_keyBind","_keyName","_a"];
_br = toString [13,10];//(carriage return & line feed)
_tab = toString [9]; // tab
_myMods = profileNamespace getVariable "cba_keybinding_registrynew" select 0;
_myResult = " ";
{
	_myActualMod = _x;
	_myModsComand = ((((profileNamespace getVariable "cba_keybinding_registrynew") select 1) select _forEachIndex) select 0);
		
		{	
			//copytoclipboard str [_myActualMod, _x];
			_mycomando = [_myActualMod, _x] call cba_fnc_getKeybind;
			if (isNil "_mycomando") then 
			{
			_myResult = _myResult  + _myActualMod + _tab + _x + _tab + "nicht zugeordnet" + _br;
			}
			else
			{ 
			_modName = _mycomando select 0;
			_actionName = _mycomando select 1;
			_displayName = _mycomando select 2;			
			_displayName = _displayName call invalid_letters;
			_keyBind  = _mycomando select 5; // [DIK code, [shift, ctrl, alt]]
			if (_keyBind select 0 >= 0) then {
				_keyName = keyImage (_keyBind select 0);
				_keyName = _keyName call invalid_letters;
				_keyName = toArray _keyName;
				_keyName resize ((count _keyName) -1);
				_keyName deleteat 0;
				_a = str (_keyBind select 1);
				switch (_a) do {
					case "[true,false,false]": { _keyName = toArray "Shift" + toArray " " + _keyName};
					case "[false,false,true]": { _keyName = toArray "Alt" + toArray " " + _keyName };
					case "[false,true,false]": { _keyName = toArray "Strg" + toArray " " + _keyName };
					case "[true,true,false]": { _keyName = toArray "Shift Strg" + toArray " " + _keyName };
					case "[true,false,true]": { _keyName = toArray "Shif Alt" + toArray " " + _keyName };
					
					// tostring (toArray "Shift" + toArray " " + a)
					// a = toarray keyname 28  ;
					// a resize (count a -1);
					// a deleteat 
					// default { _keyName = "irgendwas" };
				};
				_keyName = toString _keyName;
				
				
				_myResult = _myResult +  _modName + _tab + _actionName + _tab + _displayName + _tab +  _keyName + _tab + str _keyBind +_br;
				
				
				} else
				{
				
				_myResult = _myResult +  _modName + _tab + _actionName + _tab + _displayName + _tab +  "not defined" + _tab + str _keyBind +_br;
				
				};
			};
		}forEach _myModsComand;




}forEach _myMods;


	_myResult;
	};


StandardKeys = {
// This function checks all standard keys in ARMA vanilla
private  ["_myActionGroups","_myActionGroupsNameArray","_myActionsArray","_myResultArray","_priority","_br","_tab","_myResult","_myActionGroupsName","_myActionsGroupTranslation","_myActions","_myKeyList","_myKeyListTranslation","_myActionKeyDIKnumericCode"];

_myActionGroups = "true" configClasses (configfile >> "UserActionGroups");
_myActionGroupsNameArray = [];
_myActionsArray = [];
_myKeyListArray = [];
_myResultArray = [];
_priority =  "Keyboard, Combo, Mouse" ;//"'Mouse','Keyboard','Stick','Gamepad','Trackir','Combo' (mouse and keyboard combinations),'Controler' (any controller other than mouse or keyboard). Other values are considered as 'Unsorted'.";
_br = toString [13,10];//(carriage return & line feed)
_tab = toString [9]; // tab
_myResult =  "";

{
	_myActionGroupsName = configname _x;
	_myActionsGroupTranslation = gettext (configfile >> "UserActionGroups" >> _myActionGroupsName >> "name"); 
	_myActionsGroupTranslation = _myActionsGroupTranslation call invalid_letters;
	_myActions = getArray (configfile >> "UserActionGroups" >> _myActionGroupsName >> "group");
	

		{
			_myKeyList =  (actionKeysNamesArray [_x, 5,_priority]);
			_myKeyList = _myKeyList call invalid_letters;
			_myKeyListTranslation = actionName _x;
			_myKeyListTranslation = _myKeyListTranslation call invalid_letters;
			//_myKeyListTranslation = _myKeyListTranslation call invalid_letters;
			_myActionKeyDIKnumericCode = (actionKeys _x);
			
			if (isNil "_myActionKeyDIKnumericCode" ) then {_myActionKeyDIKnumericCode = -10;};
			
			
			
			_myResult = _myResult + _myActionGroupsName + _tab +  (_myActionsGroupTranslation) + _tab + _x + _tab +  (_myKeyListTranslation) + _tab + (_myKeyList)  + _tab + str (_myActionKeyDIKnumericCode) + _br;
			
			
			
			
		} forEach _myActions;
	
	

}forEach _myActionGroups;

_myResult;
};

private ["_modsInstalled","_myResult","_myResultWithMods","_myResultWithOutMods"];

_myResult = "";
_myResultWithMods = "";
_myResultWithOutMods = "";
_modsInstalled = false;

_modsInstalled = call modsinstalled;


if(_modsInstalled)
	then {
	_myResultWithOutMods = call StandardKeys;
	_myResultWithMods = call ModKeys;
	_myResult = _myResultWithOutMods + _myResultWithMods;
	} else
	{	
	_myResult = call StandardKeys;
	};


copytoclipboard str _myResult;
hint "all keys copied to clipboard";