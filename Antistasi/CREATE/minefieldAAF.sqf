#include "../macros.hpp"
if (!isServer and hasInterface) exitWith {false};
params ["_marcador", "_base"];
private ["_posbase","_posmarcador","_angOrig","_ang","_intentos","_distancia","_pos","_fallo","_mina"];

if (spawner getVariable _base) exitWith {false};

private _posbase = getMarkerPos _base;
private _posmarcador = getMarkerPos _marcador;
private _angOrig = [_posbase,_posmarcador] call BIS_fnc_dirTo;

private _distancia = 300;
private _searchAng = 5;
private _searchAmplitude = 50;
// find a suitable spot for mines that is:
// 	- in land
//	- far from spawned location
//	- far from location
// 	- far from road
// 	- without mines closeby
private _pos = [];
private _found = false;
private _ang = _angOrig;
for "_i" from 1 to (_searchAmplitude/_searchAng) do {
	_pos = [_posbase, _distancia, _ang] call BIS_Fnc_relPos;

	if (!surfaceIsWater _pos) then {
		_cercano = [marcadores,_pos] call BIS_fnc_nearestPosition;
		if (not(spawner getVariable _cercano)) then {
			private _size = [_cercano] call sizeMarker;
			if ((_pos distance (getMarkerPos _cercano)) > (_size + 100)) then {
				private _road = [_pos,101] call BIS_fnc_nearestRoad;
				if (isNull _road) then {
					if ({_x distance _pos < 100} count allMines == 0) then {
						_found = true;
					};
				};
			};
		};
	};
	if (_found) exitWith {};

	// +5 (+5), -10 (-5), +15 (+10), ... so it searches the 45 arc starting from the middle
	// last _i, ang = _angOrig + _searchAmplitude/2;
	if (_i % 2 == 1) then {
		_ang = _ang + _searchAng*_i;
	} else {
		_ang = _ang - _searchAng*_i;
	};
};

if (_found) exitWith {false};

for "_i" from 1 to 60 do {
	private _mina = createMine ["APERSMine",_pos,[],100];
	side_green revealMine _mina;
};

true
