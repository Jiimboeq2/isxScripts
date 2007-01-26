;*************************************************************
;Defiler.iss
;version 20061201a
;by karye
;Fixed Cyrstalize Spirit line
;implemented EoF Mastery attacks
;implemented Turgur's Spirit Sight
;implemented Vampire Theft Of Vitality
;Implemented AA Cannibalize
;Implemented AA Hexation
;Implemented AA Soul Ward
;Fixed a bug with AE healing group members out of zone
;Fixed a bug with curing uncurable afflictions
;The defiler will now use spiritual circle more often
;*************************************************************
#includeoptional "\\Athena\innerspace\Scripts\EQ2Bot\Class Routines\EQ2BotLib.iss"

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	declare OffenseMode bool script 0
	declare DebuffMode bool script 0 	
 	declare AoEMode bool script 0
 	declare CureMode bool script 0
 	declare MaelstromMode bool script 0
	declare KeepWardUp bool script
	
	declare BuffNoxious bool script FALSE
	declare BuffMitigation bool script FALSE
	declare BuffStrength bool script FALSE
	declare BuffWaterBreathing bool script FALSE
	declare BuffProcGroupMember string script
	declare BuffHorrorGroupMember string script
	
	declare EquipmentChangeTimer int script
	
	declare MainWeapon string script
	declare OffHand string script
	declare OneHandedSpear string script
	declare TwoHandedSpear string script
	declare Symbols string script
	declare Buckler string script
	declare Staff string script
	
	
	
	call EQ2BotLib_Init
	
	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,FALSE]}]
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	CureMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Cure Spells,FALSE]}]
	MaelstromMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Maelstrom Mode,FALSE]}]
	KeepWardUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepWardUp,FALSE]}]

	BuffNoxious:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffNoxious,TRUE]}]
	BuffMitigation:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffMitigation,TRUE]}]
	BuffStrength:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffStrength,TRUE]}]
	BuffWaterBreathing:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffWaterBreathing,FALSE]}]
	BuffProcGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffProcGroupMember,]}]
	BuffHorrorGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffHorrorGroupMember,]}]
	
	MainWeapon:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[MainWeapon,]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]
	OneHandedSpear:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OneHandedSpear,]}]
	TwoHandedSpear:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[TwoHandedSpear,]}]
	Symbols:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[WeaponSymbols,]}]
	Buckler:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buckler,]}]
	Staff:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Staff,]}]	
}
 
function Buff_Init()
{
	
	PreAction[1]:Set[BuffPower]
	PreSpellRange[1,1]:Set[35]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]
	PreSpellRange[2,2]:Set[26]

	PreAction[3]:Set[BuffProc]
	PreSpellRange[3,1]:Set[41]
	
	PreAction[4]:Set[BuffNoxious]
	PreSpellRange[4,1]:Set[23]

	PreAction[5]:Set[Group_Buff]
	PreSpellRange[5,1]:Set[281]
	PreSpellRange[5,2]:Set[283]

	PreAction[6]:Set[SpiritCompanion]
	PreSpellRange[6,1]:Set[385]
	
	PreAction[7]:Set[AA_AuraOfHaste]
	PreSpellRange[7,1]:Set[389]
	
	PreAction[8]:Set[AA_AuraOfWarding]
	PreSpellRange[8,1]:Set[390]	
	
	PreAction[9]:Set[SpecialVision]
	PreSpellRange[9,1]:Set[314]
	
	PreAction[10]:Set[AA_SpiritualForesight]
	PreSpellRange[10,1]:Set[391]
	
	PreAction[11]:Set[AA_Immunities]
	PreSpellRange[11,1]:Set[383]	

	PreAction[12]:Set[AA_RitualisticAggression]
	PreSpellRange[12,1]:Set[396]	
	PreSpellRange[12,2]:Set[397]
	
	PreAction[13]:Set[xxxxx]
	PreSpellRange[13,1]:Set[999]	
	
	PreAction[14]:Set[AA_InfectiveBites]
	PreSpellRange[14,1]:Set[394]	
	
	PreAction[15]:Set[AA_Coagulate]
	PreSpellRange[15,1]:Set[395]

	PreAction[16]:Set[AA_Virulence]
	PreSpellRange[16,1]:Set[399]
	
	PreAction[17]:Set[BuffHorror]
	PreSpellRange[17,1]:Set[40]

	PreAction[18]:Set[BuffMitigation]
	PreSpellRange[18,1]:Set[21]
	
	PreAction[19]:Set[BuffStrength]
	PreSpellRange[19,1]:Set[20]
	
	PreAction[20]:Set[BuffWaterBreathing]
	PreSpellRange[20,1]:Set[280]
	
}
 
function Combat_Init()
{

	Action[1]:Set[AoE1]
	SpellRange[1,1]:Set[90]
	
	Action[2]:Set[AoE2]
	SpellRange[2,1]:Set[91]	
	
	Action[3]:Set[AARabies]
	SpellRange[3,1]:Set[352]

	Action[4]:Set[Proc_Ward]
	MobHealth[4,1]:Set[1]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[1]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[322]
	
	Action[5]:Set[Malaise]
	MobHealth[5,1]:Set[1]
	MobHealth[5,2]:Set[100]
	Power[5,1]:Set[1]
	Power[5,2]:Set[100]
	SpellRange[5,1]:Set[71]
	
	Action[6]:Set[Imprecation]
	MobHealth[6,1]:Set[1]
	MobHealth[6,2]:Set[100]
	Power[6,1]:Set[60]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[80]

	Action[7]:Set[AA_Hexation]
	MobHealth[7,1]:Set[1]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[20]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[382]
	
	Action[8]:Set[TheftOfVitality]
	MobHealth[8,1]:Set[1]
	MobHealth[8,2]:Set[100]
	Power[8,1]:Set[20]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[55]
	
	Action[9]:Set[Mastery]
	SpellRange[9,1]:Set[360]
	SpellRange[9,2]:Set[379]

	Action[10]:Set[UmbralTrap]
	MobHealth[10,1]:Set[1]
	MobHealth[10,2]:Set[100]
	SpellRange[10,1]:Set[54]	
	
	Action[11]:Set[Fuliginous_Sphere]
	MobHealth[11,1]:Set[1]
	MobHealth[11,2]:Set[100]
	Power[11,1]:Set[1]
	Power[11,2]:Set[100]
	SpellRange[11,1]:Set[51]
	
	Action[12]:Set[Curse]
	MobHealth[12,1]:Set[1]
	MobHealth[12,2]:Set[100]
	Power[12,1]:Set[1]
	Power[12,2]:Set[100]
	SpellRange[12,1]:Set[50]

	Action[13]:Set[Loathsome_Seal]
	MobHealth[13,1]:Set[1]
	MobHealth[13,2]:Set[100]
	Power[13,1]:Set[1]
	Power[13,2]:Set[100]
	SpellRange[13,1]:Set[53]	

	Action[14]:Set[Repulsion]
	MobHealth[14,1]:Set[1]
	MobHealth[14,2]:Set[100]
	Power[14,1]:Set[1]
	Power[14,2]:Set[100]
	SpellRange[14,1]:Set[52]
		
	Action[15]:Set[ThermalShocker]

	Action[16]:Set[AA_CripplingBash]
	MobHealth[16,1]:Set[1]
	MobHealth[16,2]:Set[100]
	SpellRange[16,1]:Set[393]
	
	Action[17]:Set[UmbralTrap]
	MobHealth[17,1]:Set[1]
	MobHealth[17,2]:Set[100]
	SpellRange[17,1]:Set[54]		
}
 
function PostCombat_Init()
{
	PostAction[1]:Set[Resurrection]
	PostSpellRange[1,1]:Set[300]
	PostSpellRange[1,2]:Set[301]
	
	PostAction[2]:Set[LoadDefaultEquipment]	
}
 
function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	
	variable int temp

	call WeaponChange
	
	ExecuteAtom CheckStuck

	if ${ShardMode}
	{
		call Shard
	}
	
	call CheckHeals


	
	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}
	
	if ${Me.ToActor.Power}>85 && ${KeepWardUp}
	{
		call CastSpellRange 15
		call CastSpellRange 7 0 0 0 ${Actor[${MainAssist}].ID}
	}


	switch ${PreAction[${xAction}]}
	{
		case BuffPower
			Counter:Set[1]
			tempvar:Set[1]

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{				

							BuffTarget:Set[${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]
							
							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}
							
							
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
						;we went through the buff collection and had no match for this maintaned target so cancel it
						if !${BuffMember.Equal[OK]}
						{
							;we went through the buff collection and had no match for this maintaned target so cancel it
							Me.Maintained[${Counter}]:Cancel
						}
					}
					else
					{
						;our buff member collection is empty so this maintained target isnt in it
						Me.Maintained[${Counter}]:Cancel
					}
				}
				
			}
			while ${Counter:Inc}<=${Me.CountMaintained} 			
			

			Counter:Set[1]
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{

				do
				{				
					BuffTarget:Set[${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break	
		case SpiritCompanion
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case AA_Coagulate
			if ${Actor[${MainAssist}](exists)} 
			{ 
				;If the MA changed during the fight cancel so we can rebuff original MA
				if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}!=${Actor[${MainAssist}].ID}
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${MainAssist}].ID}
			} 
			break 
		case BuffNoxious
			if ${BuffNoxious}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffMitigation
			if ${BuffMitigation}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffStrength
			if ${BuffStrength}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffWaterBreathing
			if ${BuffWaterBreathing}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break			
		case BuffProc
			BuffTarget:Set[${UIElement[cbBuffProcGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}			

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break		
		case BuffHorror
			BuffTarget:Set[${UIElement[cbBuffHorrorGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}			

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break	
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		case Resurrection
			temp:Set[1]
			do
			{
				if ${Me.Group[${temp}].ToActor.Health}==-99 && ${Me.Group[${temp}].ToActor(exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 1 0 ${Me.Group[${temp}].ID} 1
				}
			}
			while ${temp:Inc}<${Me.GroupCount}
			break
		case AA_Immunities			
		case AA_AuraOfHaste
			if !${Me.ToActor.Effect[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Me.ToActor.Pet(exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break
		case AA_SpiritualForesight
		case AA_RitualisticAggression
		case AA_RitualOfAbsolution
		case AA_InfectiveBites
		case AA_Virulence
		case AA_AuraOfWarding
			if ${Me.ToActor.Pet(exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			}
			break

		case SpecialVision
			if ${Me.ToActor.Race.Equal[Euridite]}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
		Default
			xAction:Set[20]
			break
	}
}
 
function Combat_Routine(int xAction)
{

	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}
	
	call CheckGroupHealth 75
	if ${DoHOs} && ${Return}
	{
		objHeroicOp:DoHO
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}
	
	ExecuteAtom PetAttack	
		
	call CheckHeals
	call RefreshPower
	
	;keep Leg Bite up at all times if we have a pet
	if ${Me.Maintained[${SpellType[385]}](exists)}
	{
		if ${Me.Equipment[1].Name.Equal[${OneHandedSpear}]}
		{
			call CastSpellRange 388
		}
		elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
		{
			Me.Inventory[${OneHandedSpear}]:Equip
			EquipmentChangeTimer:Set[${Time.Timestamp}]
			call CastSpellRange 388
		}		
	}	
	

	
	if ${ShardMode}
	{
		call Shard
	}

	if ${MaelstromMode}
	{
		call CheckGroupHealth 60

		if ${Return}
		{
			call CastSpellRange 317
		}
		elseif ${Me.Maintained[${SpellType[317]}](exists)}
		{
			Me.Maintained[${SpellType[317]}]:Cancel
		}
		
	}
	elseif ${Me.Maintained[${SpellType[317]}](exists)}
	{
		Me.Maintained[${SpellType[317]}]:Cancel
	}
	;Before we do our Action, check to make sure our group doesnt need healing
	call CheckGroupHealth 75
	if ${Return}
	{	
		switch ${Action[${xAction}]}
		{
			case Repulsion
			case Loathsome_Seal
			case Curse
			case UmbralTrap
			case TheftOfVitality
			case AA_Hexation
				if ${DebuffMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}

						}
					}
				}
				break
			case AA_CripplingBash
				;note: will only bash if within 5 meters, this is by design to prevent having to implement a range only mode
				if ${DebuffMode} && ${Me.Maintained[${SpellType[385]}](exists)}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							if ${Me.Equipment[1].Name.Equal[${Buckler}]}
							{
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
							}
							elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
							{
								Me.Inventory[${Buckler}]:Equip
								EquipmentChangeTimer:Set[${Time.Timestamp}]
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
							}

						}
					}
				}
				break

			case Proc_Ward
				if (${Actor[${KillTarget}].Difficulty} == 3)  || ${MainTank} || ${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Type.Equal[NamedNPC]}
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}

					}
				}
				break
			case Forced_Cannibalize
			case Malaise
			case Imprecation			
			case Fuliginous_Sphere
				if ${OffenseMode}
					{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
						}
					}
				}
				break
			case Soul_Essence
				if ${OffenseMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckHealerMob
						if ${Return}
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
						}
					}
				}
				break

			case AoE1
			case AoE2
			case AARabies
				if ${AoEMode}  
				{
					if ${Mob.Count}>2
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break
			case Mastery
				if ${OffenseMode} || ${DebuffMode}
				{		
					if ${Me.Ability[Orc Master's Sinister Strike].IsReady} || ${Me.Ability[Orc Master's Sinister Strike].IsReady}
					{
						Target ${KillTarget}
						Me.Ability[Orc Master's Smite]:Use
						;Me.Ability[Gnoll Master's Smite]:Use
						Me.Ability[Ghost Master's Smite]:Use
						Me.Ability[Elemental Master's Smite]:Use
						;Me.Ability[Skeleton Master's Smite]:Use
						;Me.Ability[Zombie Master's Smite]:Use
						;Me.Ability[Centaur Master's Smite]:Use
						Me.Ability[Giant Master's Smite]:Use
						;Me.Ability[Treant Master's Smite]:Use
						;Me.Ability[Fairy Master's Smite]:Use
						Me.Ability[Goblin Master's Smite]:Use
						;Me.Ability[Golem Master's Smite]:Use
						;Me.Ability[Bixie Master's Smite]:Use
						Me.Ability[Cyclops Master's Smite]:Use
						;Me.Ability[Djinn Master's Smite]:Use
						;Me.Ability[Harpy Master's Smite]:Use
						;Me.Ability[Naga Master's Smite]:Use
						Me.Ability[Droag Master's Smite]:Use
						;Me.Ability[Aviak Master's Smite]:Use
						;Me.Ability[Beholder Master's Smite]:Use
						;Me.Ability[Ravasect Master's Smite]:Use
						Me.Ability[Werewolf Master's Smite]:Use
						;Me.Ability[Bugbear Master's Smite]:Use
						;Me.Ability[Brownie Master's Smite]:Use
						;Me.Ability[Clockwork Master's Smite]:Use
						Me.Ability[Minotaur Master's Smite]:Use
						;Me.Ability[Kobold Master's Smite]:Use							
					}
				}
				break	
			case ThermalShocker
				if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady}
				{
					Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
				}

			default
				xAction:Set[20]
				break
		}
	}
}
 
function Post_Combat_Routine(int xAction)
{
	
	;Turn off Maelstrom so we can move
	if ${Me.Maintained[${SpellType[317]}](exists)}
	{
		Me.Maintained[${SpellType[317]}]:Cancel
	}
	
	TellTank:Set[FALSE]	
	
	if ${Me.AutoAttackOn} 
	{

		EQ2Execute /toggleautoattack
	}
	
	switch ${PostAction[${xAction}]}
	{
		case Resurrection
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}].ToActor.Health}==-99
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 1 0 ${Me.Group[${tempgrp}].ID} 1
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break
		case LoadDefaultEquipment
			ExecuteAtom LoadEquipmentSet "Default"
		default
			xAction:Set[20]
			break
	}
}

function Have_Aggro()
{
	
	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTank}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}
	
	if !${MainTank}
	{
		;Try AE fear hate reduction first
		call CastSpellRange 180
		
		;if something is still on me single fear it
		if ${Actor[${aggroid}].Distance}<=5 && (${Actor[${aggroid}].Target.ID} == ${Me.ID})
		{
			call CastSpellRange 181 0 0 0 ${aggroid}
		}		
		
	}



}
function RefreshPower()
{

	;AA Cannibalize
	if ${Me.ToActor.Power}<35  && ${Me.ToActor.Health}>50
	{
		call CastSpellRange 381
	}
	
	;Forced Canabalize
	if ${Me.ToActor.Power}<85 && ${Me.InCombat}
	{
		call CastSpellRange 72 0 0 0 ${KillTarget}
	}
	
	if ${Me.InCombat} && ${Me.ToActor.Power}<65  && ${Me.ToActor.Health}>25
	{
		call UseItem "Tribal Spiritist's Hat"
	}
	
	if ${Me.InCombat} && ${Me.ToActor.Power}<45
	{
		call UseItem "Spiritise Censer"
	}
	
	if ${Me.InCombat} && ${Me.ToActor.Power}<15
	{
		call UseItem "Stein of the Everling Lord"
	}	
	
}

function CheckHeals()
{
	declare temphl int local
	declare grpheal int local 0
	declare lowest int local 0
	declare grpcure int local 0
	declare mostafflicted int local 0
	declare mostafflictions int local 0
	declare tmpafflictions int local 0
	declare PetToHeal int local 0
	
	grpcnt:Set[${Me.GroupCount}]
	hurt:Set[FALSE]

	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]
	
	;Res the MT if they are dead
	if ${Actor[PC,${MainAssist}].Health}==-99 && ${Actor[PC,${MainAssist}](exists)}
	{
		call CastSpellRange 300 0 0 0 ${Actor[${MainAssist}].ID}
	}

	do
	{
		if ${Me.Group[${temphl}].ToActor(exists)}
		{

			if ${Me.Group[${temphl}].ToActor.Health}==-99 && !${Me.InCombat}
			{
				call CastSpellRange 300 301 1 0 ${Me.Group[${temphl}].ID} 1
			}

			if ${Me.Group[${temphl}].ToActor.Health}<100 && ${Me.Group[${temphl}].ToActor.Health}>-99
			{
				if ${Me.Group[${temphl}].ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health}
				{
					lowest:Set[${temphl}]
				}
			}

			if ${Me.Group[${temphl}].IsAfflicted}

			{
				if ${Me.Group[${temphl}].Arcane}>0
				{
					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Arcane}]}]
				}

				if ${Me.Group[${temphl}].Noxious}>0
				{
					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Noxious}]}]
				}
				
				if ${Me.Group[${temphl}].Elemental}>0
				{
					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Elemental}]}]
				}
				
				if ${Me.Group[${temphl}].Trauma}>0
				{
					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Trauma}]}]
				}
				
				if ${tmpafflictions}>${mostafflictions}
				{
					mostafflictions:Set[${tmpafflictions}]
					mostafflicted:Set[${temphl}]
				}
			}

			if ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}].ToActor.Health}<80
			{
				grpheal:Inc
			}

			if ${Me.Group[${temphl}].Noxious}>0 || ${Me.Group[${temphl}].Trauma}>0 
			{
				grpcure:Inc
			}

			if ${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]}
			{
				if ${Me.Group[${temphl}].ToActor.Pet.Health}<60 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0
				{
					PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}
				}
			}
			
			if ${Me.ToActor.Pet.Health}<60
			{
				PetToHeal:Set[${Me.ToActor.Pet.ID}]

			}			
			
		}

	}
	while ${temphl:Inc}<${grpcnt}

	if ${Me.ToActor.Health}<80 && ${Me.ToActor.Health}>-99
	{
		grpheal:Inc
	}
	
	if ${Me.Noxious}>0 || ${Me.Trauma}>0
	{
		grpcure:Inc
	}
	
	;CURES
	if ${grpcure}>2 && ${CureMode}
	{
		call CastSpellRange 220
	}
	
	if ${Me.IsAfflicted} && ${CureMode}
	{
		call CureMe
	}

	if ${mostafflicted} && ${CureMode}
	{
		call CureGroupMember ${mostafflicted}
	}
	
	;MAINTANK EMERGENCY HEAL
	if ${Me.Group[${lowest}].ToActor.Health}<30 && ${Me.Group[${lowest}].Name.Equal[${MainAssist}]} && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)}
	{
		call EmergencyHeal ${Actor[${MainAssist}].ID}
	}
	
	;ME HEALS
	if ${Me.ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.ToActor.Health}<70 && ${Me.ToActor.InCombatMode}
		{
			
			; if i have summoned a defiler crystal use that to heal first
			if ${Me.Inventory[Crystallized Spirit](exists)}
			{
				Me.Inventory[Crystallized Spirit]:Use
			}
			
		}
		
		if ${Me.ToActor.Health}<85 
		{
			if ${haveaggro} && ${Me.ToActor.InCombatMode}
			{
				call CastSpellRange 7 0 0 0 ${Me.ID}
			}
			else
			{
				call CastSpellRange 351
				call CastSpellRange 4 0 0 0 ${Me.ID}
			}
		}
	
		if ${Me.ToActor.Health}<25
		{
			if ${haveaggro}
			{
				call EmergencyHeal ${Me.ID}
			}
			else
			{
				if ${Me.Ability[${SpellType[1]}].IsReady}
				{
					call CastSpellRange 351
					call CastSpellRange 1 0 0 0 ${Me.ID}
				}
				else
				{
					call CastSpellRange 351
					call CastSpellRange 4 0 0 0 ${Me.ID}
				}
			}
		}

	}
	
	;MAINTANK HEALS
	if ${Actor[${MainAssist}].Health} <90 && ${Actor[${MainAssist}](exists)} && ${Actor[${MainAssist}].InCombatMode} && ${Actor[${MainAssist}].Health}>-99
	{
		call CastSpellRange 7 0 0 0 ${Actor[${MainAssist}].ID}
		call CastSpellRange 15
	}
	
	if ${Actor[${MainAssist}].Health} <90 && ${Actor[${MainAssist}].Health} >-99 && ${Actor[${MainAssist}](exists)}
	{
		call CastSpellRange 351
		call CastSpellRange 1 0 0 0 ${Actor[${MainAssist}].ID}
	}

	;GROUP HEALS
	if ${grpheal}>=1
	{
		; Cast spiritual circle
		call CastSpellRange 16
	}	
	
	if ${grpheal}>2
	{
		if ${Me.Ability[${SpellType[10]}].IsReady}
		{
			call CastSpellRange 10
		}
	}

	if ${Me.Group[${lowest}].ToActor.Health}<80 && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.Ability[${SpellType[1]}].IsReady}
		{
			call CastSpellRange 351
			call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}

		}
		else
		{
			call CastSpellRange 351
			call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}

		hurt:Set[TRUE]
	}
	
	;PET HEALS
	if ${PetToHeal} && ${Actor[${PetToHeal}](exists)}
	{
		if ${Actor[${PetToHeal}].InCombatMode}
		{
			call CastSpellRange 7 0 0 0 ${PetToHeal}	
		}
		else
		{
			call CastSpellRange 351
			call CastSpellRange 1 0 0 0 ${PetToHeal}
		}
	}
	
	;Res Fallen Groupmembers only if in range
	grpcnt:Set[${Me.GroupCount}]
	tempgrp:Set[1]
	do
	{
		if ${Me.Group[${tempgrp}].ToActor.Health}==-99 && ${Me.Group[${tempgrp}].ToActor(exists)}
		{
			call CastSpellRange 300 301 0 0 ${Me.Group[${tempgrp}].ID} 1
		}
	}
	while ${tempgrp:Inc}<${grpcnt}
	
	call UseCrystallizedSpirit 60

}

function EmergencyHeal(int healtarget)
{

	;Soul Ward
	call CastSpellRange 380 0 0 0 ${healtarget}
	
	;if we cast soulward exit emergency heal
	if ${Me.Maintained[${SpellType[380]}](exists)}
	{
		return
	}
	
	;Avenger Death Save
	call CastSpellRange 338 0 0 0 ${healtarget}

	if ${Me.Ability[${SpellType[335]}].IsReady}
	{
		call CastSpellRange 335 0 0 0 ${healtarget}
	}
	else
	{
		call CastSpellRange 334 0 0 0 ${healtarget}
	}

}

function CheckHealerMob()
{
	declare tcount int local 2

	EQ2:CreateCustomActorArray[byDist,15]
	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]}
		{
			switch ${CustomActor[${tcount}].Class}
			{			
				case templar
				case inquisitor
				case fury
				case warden
				case defiler
				case mystic
					return TRUE
			}
		}
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

	return FALSE
}
 
function Lost_Aggro()
{
 
}
 
function MA_Lost_Aggro()
{
 
}
 
function MA_Dead()
{
	if ${Actor[${MainAssist}].Health}==-99 && ${Actor[${MainAssist}](exists)}
	{
		call 300 301 0 0 ${Actor[${MainAssist}].ID} 1
	} 
}

function CureMe()
{
	if ${Me.Arcane}>0
	{
		call CastSpellRange 326
		
		if ${Me.Arcane}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.ID}
			return
		}
	}
	
	if  ${Me.Noxious}>0
	{
		call CastSpellRange 213 0 0 0 ${Me.ID}
		return
	}

	if  ${Me.Elemental}>0
	{
		call CastSpellRange 211 0 0 0 ${Me.ID}
		return
	}

	if  ${Me.Trauma}>0
	{
		call CastSpellRange 212 0 0 0 ${Me.ID}
		return
	}
	
	
}

function CureGroupMember(int gMember)
{
	declare tmpcure int local

	tmpcure:Set[0]
	if !${Me.Group[${gMember}].ToActor(exists)}
	{
		return
	}
	
	do
	{
		if  ${Me.Group[${gMember}].Arcane}>0
		{
			call CastSpellRange 326
			
				if  ${Me.Group[${gMember}].Arcane}
				{
					call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
				}
		}

		if  ${Me.Group[${gMember}].Noxious}>0
		{
			call CastSpellRange 213 0 0 0 ${Me.Group[${gMember}].ID}
		}

		if  ${Me.Group[${gMember}].Elemental}>0
		{
			call CastSpellRange 211 0 0 0 ${Me.Group[${gMember}].ID}
		}

		if  ${Me.Group[${gMember}].Trauma}>0
		{
			call CastSpellRange 212 0 0 0 ${Me.Group[${gMember}].ID}
		}
	}
	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<3 && ${Me.Group[${gMember}].ToActor(exists)}
}

function WeaponChange()
{

	;equip main hand
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${MainWeapon}]}
	{
		Me.Inventory[${MainWeapon}]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}	

	;equip off hand
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[2].Name.Equal[${OffHand}]} && !${Me.Equipment[1].WieldStyle.Find[Two-Handed]}
	{
		Me.Inventory[${OffHand}]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

}