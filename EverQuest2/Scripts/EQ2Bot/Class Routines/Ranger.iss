;Ranger.iss 20100712a by Pygar

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif


function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20100712
  ;;;;
    
	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare BowAttacksMode bool script TRUE
	declare RangedAttackMode bool script TRUE
	declare SurroundingAttacksMode bool Script FALSE

	call EQ2BotLib_Init

	BowAttacksMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Bow Attack Spells,FALSE]}]
	RangedAttackMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Ranged Attacks Only,FALSE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]
	SurroundingAttacksMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Surrounding Attacks,FALSE]}]
}

function Pulse()
{
	;;;;;;;;;;;;
	;; Note:  This function will be called every pulse, so intensive routines may cause lag.  Therefore, the variable 'ClassPulseTimer' is 
	;;        provided to assist with this.  An example is provided.
	;
	;			if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+2000]})
	;			{
	;				Debug:Echo["Anything within this bracket will be called every two seconds.
	;			}         
	;
	;         Also, do not forget that a 'pulse' of EQ2Bot may take as long as 2000 ms.  So, even if you use a lower value, it may not be called
	;         that often (though, if the number is lower than a typical pulse duration, then it would automatically be called on the next pulse.)
	;;;;;;;;;;;;

	if (${StartBot} && ${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+20000]})
	{
		ClassPulseTimer:Set[${Script.RunningTime}]
		ISXEQ2:ClearAbilitiesCache
	}  
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[Reflexes]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[PathFinding]
	PreSpellRange[2,1]:Set[26]

	PreAction[3]:Set[AA_Surrounding_Attacks]
	PreSpellRange[3,1]:Set[396]

	PreAction[4]:Set[AA_Neurotoxic_Coating]
	PreSpellRange[4,1]:Set[391]
	
	PreAction[5]:Set[Stance]
	PreSpellRange[5,1]:Set[291]
	PreSpellRange[5,1]:Set[295]
	
	PreAction[6]:Set[MakeShift]
	PreSpellRange[6,1]:Set[302]
}

function Combat_Init()
{

}

function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{

	switch ${PreAction[${xAction}]}
	{
		case AA_Surrounding_Attacks
			if ${SurroundingAttacksMode}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Stance
			if ${MainTank}
				call CastSpellRange ${PreSpellRange[${xAction},2]} 0 0 0 0 0 0 1
			else
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 1
			break
		case MakeShift
		case PathFinding
		case AA_Neurotoxic_Coating
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Reflexes
			if !${MainTank}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 1
			}
			break
		Default
			return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{
	if !${MainTank}
		eq2execute /auto 2
		
	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${Me.IsStealthed} && !${MainTank}
	{
		if ${Me.Ability[${SpellType[260]}].TimeUntilReady}<.1
		{
			Me.Ability[${SpellType[260]}]:Use
			eq2echo waiting on 260
			wait 10
		}
		elseif ${Me.Ability[${SpellType[131]}].TimeUntilReady}<.1
		{
			Me.Ability[${SpellType[131]}]:Use
			eq2echo waiting on 131
			wait 10
		}
		elseif ${Me.Ability[${SpellType[262]}].TimeUntilReady}<.1
		{
			Me.Ability[${SpellType[262]}]:Use
			eq2echo waiting on 262
			wait 10
		}
		elseif ${Me.Ability[${SpellType[261]}].TimeUntilReady}<.1
		{
			Me.Ability[${SpellType[261]}]:Use	
			echo echo waiting on 261
			wait 10
		}
	}
	declare spellsused int local
	declare spellthreshold int local

	spellsused:Set[0]
	spellthreshold:Set[2]

	if ${MainTank}
	{
		eq2echo I'm a main tank yo
		;;;;Bladed Opening
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[380]}].IsReady}
		{
			call CastSpellRange 380 0 0 0 ${KillTarget}
			spellsused:Inc
		}	

		;;;;Bloody Reminder
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[160]}].IsReady} && !${Me.Maintained[${SpellType[160]}](exists)}
		{
			call CastSpellRange 160 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		;;;;Lightning Strike
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[150]}].IsReady}
		{
			call CastSpellRange 150 0 0 0 ${KillTarget}
			spellsused:Inc
		}	

		;;;;Arrow Rip
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[151]}].IsReady}
		{
			call CastSpellRange 151 0 0 0 ${KillTarget}
			spellsused:Inc
		}	

		;;;;Immobilizing Lunge
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[152]}].IsReady}
		{
			call CastSpellRange 152 0 0 0 ${KillTarget}
			spellsused:Inc
		}	

		;;;;Point Blank Shot
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[398]}].IsReady}
		{
			call CastSpellRange 398 0 0 0 ${KillTarget}
			spellsused:Inc
		}	

		;;;;Snipe
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[192]}].IsReady} && !${Me.Maintained[${SpellType[192]}](exists)}
		{
			call CastSpellRange 192 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		return CombatComplete
	}



	
	if ${Actor[${KillTarget}].Name(exists)} && ${Actor[${KillTarget}].Distance}>25
	{
		echo We are over 25 Meters
		call FastMove ${Actor[${KillTarget}].X} ${Actor[${KillTarget}].Z} 10 1 1
	}
	
	if ${Actor[${KillTarget}].Name(exists)} && ${Actor[${KillTarget}].Distance}<8
	{
		echo We are under 8 meters
		press -hold s
		do
		{
			wait 1
		}
		while ${Target(exists)} && ${Target.Distance}<8
		press -release s
		
	}
	;;;Tempbuffs
	if ${Actor[${KillTarget}].IsHeroic} || ${Actor[${KillTarget}].IsEpic}
	{
		;;;;Focus Aim
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[230]}].IsReady} && !${Me.Maintained[${SpellType[230]}](exists)}
		{
			call CastSpellRange 230 0 0 0 ${KillTarget}
			spellsused:Inc
		}		
		elseif (!${spellsused} || ${Actor[${KillTarget}].IsEpic}) && ${Me.Ability[${SpellType[232]}].IsReady} && !${Me.Maintained[${SpellType[232]}](exists)}
		{
			call CastSpellRange 232 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		elseif (!${spellsused} || ${Actor[${KillTarget}].IsEpic}) && ${Me.Ability[${SpellType[231]}].IsReady} && !${Me.Maintained[${SpellType[231]}](exists)}
		{
			call CastSpellRange 231 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}

	;;;;Stream of Arrows
	if ${Mob.Count}>2 && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[256]}].IsReady}
	{
		call CastSpellRange 256 0 0 0 ${KillTarget}
		spellsused:Inc
	}	

	;;;;Storm of Arrows
	if ${Actor[${KillTarget}].EncounterSize}>1 && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[255]}].IsReady}
	{
		call CastSpellRange 255 0 0 0 ${KillTarget}
		spellsused:Inc
	}

	;;;;Bloody Reminder
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[160]}].IsReady} && !${Me.Maintained[${SpellType[160]}](exists)}
	{
		call CastSpellRange 160 0 0 0 ${KillTarget}
		spellsused:Inc
	}
	

	;;;; nifty stealth chain logic
	if ${Me.Ability[${SpellType[260]}].TimeUntilReady}<.1 || ${Me.Ability[${SpellType[261]}].TimeUntilReady}<.1 || ${Me.Ability[${SpellType[262]}].TimeUntilReady}<.1 || ${Me.Ability[${SpellType[131]}].TimeUntilReady}<.1
	{
		call CastStealth
		if ${Return}
		{
			if ${Me.Ability[${SpellType[260]}].TimeUntilReady}<.1
			{
				Me.Ability[${SpellType[260]}]:Use
				wait 3
				wait 10 !${Me.CastingSpell}
			}
			elseif ${Me.Ability[${SpellType[131]}].TimeUntilReady}<.1
			{
				Me.Ability[${SpellType[131]}]:Use
				wait 3
				wait 10 !${Me.CastingSpell}
			}
			elseif ${Me.Ability[${SpellType[262]}].TimeUntilReady}<.1
			{
				Me.Ability[${SpellType[262]}]:Use
				wait 3
				wait 10 !${Me.CastingSpell}
			}
			elseif ${Me.Ability[${SpellType[261]}].TimeUntilReady}<.1
			{ 
				Me.Ability[${SpellType[261]}]:Use
				wait 3
				wait 10 !${Me.CastingSpell}
			}
		}
	}


	;;;;Snaring Shot
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[254]}].IsReady}
	{
		call CalcAutoAttackTimer				
		if ${TimeUntilNextAutoAttack} > ${Me.Ability[${SpellType[254]}].IsReady}		
		{
			call CastSpellRange 254 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}	
	;;;;Trick Shot
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[252]}].IsReady}
	{
		call CalcAutoAttackTimer				
		if ${TimeUntilNextAutoAttack} > ${Me.Ability[${SpellType[252]}].IsReady}		
		{
			call CastSpellRange 252 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}
	
	;;;;Crippling Arrow
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[251]}].IsReady}
	{
		call CalcAutoAttackTimer				
		if ${TimeUntilNextAutoAttack} > ${Me.Ability[${SpellType[251]}].IsReady}		
		{
			call CastSpellRange 251 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}	


	;;;;Rear Shot
	if ${spellsused}<=${spellthreshold} && ((${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335))
	{
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[96]}].IsReady}
		{
			call CalcAutoAttackTimer				
			if ${TimeUntilNextAutoAttack} >  ${Me.Ability[${SpellType[96]}].ToAbilityInfo.CastingTime}				
			{
				call CastSpellRange 96 0 0 0 ${KillTarget}
				spellsused:Inc
			}
		}	
	}

	;;;;Triple Shot
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[249]}].IsReady}
	{
		call CalcAutoAttackTimer				
		if ${TimeUntilNextAutoAttack} > ${Me.Ability[${SpellType[249]}].IsReady}				
		{
			call CastSpellRange 249 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}	

	;;;;Miracle Shot
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[253]}].IsReady}
	{
		call CalcAutoAttackTimer				
		if ${TimeUntilNextAutoAttack} > ${Me.Ability[${SpellType[253]}].IsReady}		
		{
			call CastSpellRange 253 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}	

	;;;;Searing Shot
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[250]}].IsReady}
	{
		call CalcAutoAttackTimer				
		if ${TimeUntilNextAutoAttack} > ${Me.Ability[${SpellType[250]}].IsReady}			
		{
			call CastSpellRange 250 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}	




	;;;;Evasive Maneuvers
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[383]}].IsReady}
	{
		call CalcAutoAttackTimer				
		if ${TimeUntilNextAutoAttack} > ${Me.Ability[${SpellType[383]}].IsReady}		
		{
			call CastSpellRange 383 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}	

	;;;;Immobilizing Lunge
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[152]}].IsReady}
	{
		call CalcAutoAttackTimer				
		if ${TimeUntilNextAutoAttack} > ${Me.Ability[${SpellType[152]}].IsReady}		
		{
			call CastSpellRange 152 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}	

	;;;;Noxious Enfeeblement
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[382]}].IsReady}
	{
		call CalcAutoAttackTimer				
		if ${TimeUntilNextAutoAttack} > ${Me.Ability[${SpellType[382]}].IsReady}		
		{
			call CastSpellRange 382 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}
	
	;;;;Hawk Attack
	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[181]}].IsReady}
	{
		call CalcAutoAttackTimer				
		if ${TimeUntilNextAutoAttack} > ${Me.Ability[${SpellType[181]}].IsReady}		
		{
			call CastSpellRange 181 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}	

	if ${DoHOs}
		objHeroicOp:DoHO

	return CombatComplete

}

function Post_Combat_Routine(int xAction)
{

	if ${Me.AutoAttackOn}
		EQ2Execute /toggleautoattack

	;cancel stealth
	if ${Me.Maintained[Stealth](exists)}
		Me.Maintained[Stealth]:Cancel

	if ${Me.Maintained[Stalk](exists)}
		Me.Maintained[Stalk]:Cancel
}

function Have_Aggro(int agroid)
{
	;Turn on Parry AA Impenetrable
	if ${Me.Health}<30
		call CastSpellRange 395

	if ${Me.Ability[${SpellType[383]}].IsReady}
		call CastSpellRange 383 0 0 0 ${agroid} 0 0 1
	else
		call CastSpellRange 180 0 0 0 ${agroid} 0 0 1
}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{

}

function MA_Dead()
{

}

function CastStealth()
{
	echo CastStealth Called
	;sneak attack
	variable int Stealth1=195
	;stalk
	variable int Stealth2=196
	;coverage
	variable int Stealth3=197
	;AA_Smoke_Bomb
	variable int Stealth5=393
	variable int StealthCast

	StealthCast:Set[0]
	if ${Me.Ability[${SpellType[${Stealth1}]}].IsReady}
	{
		echo Casting Stealth1
		wait 20 !${Me.CastingSpell} 
		Me.Ability[${SpellType[${Stealth1}]}]:Use
		wait 4
		wait 20 !${Me.CastingSpell} 
		StealthCast:Set[1]
	}
	elseif ${Me.Ability[${SpellType[${Stealth5}]}].IsReady} && ${PBAoEMode}
	{
		echo Casting Stealth5
		wait 20 !${Me.CastingSpell} 
		Me.Ability[${SpellType[${Stealth5}]}]:Use
		wait 4
		wait 20 !${Me.CastingSpell} 
		StealthCast:Set[1]
	}
	elseif ${Me.Ability[${SpellType[${Stealth2}]}].IsReady}
	{
		echo Casting Stealth2
		wait 20 !${Me.CastingSpell} 
		Me.Ability[${SpellType[${Stealth2}]}]:Use
		wait 4
		wait 20 !${Me.CastingSpell} 
		StealthCast:Set[1]
	}
	elseif ${Me.Ability[${SpellType[${Stealth3}]}].IsReady}
	{
		echo Casting Stealth3
		wait 20 !${Me.CastingSpell} 
		Me.Ability[${SpellType[${Stealth3}]}]:Use
		wait 4
		wait 20 !${Me.CastingSpell} 
		StealthCast:Set[1]
	}


	if !${StealthCast}
	{
		echo no stealth cast
		return FALSE
	}
	else
	{
		echo steath cast
		return TRUE
	}
}

function PostDeathRoutine()
{	
	;; This function is called after a character has either revived or been rezzed
	
	return
}