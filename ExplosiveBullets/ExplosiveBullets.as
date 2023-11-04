bool bAdminsOnly = true;

array<string> strSaveIds;
array<array<int>> iSaveParams =
{
	/*0 - Enabled/Disabled; 1 - Magnitude.*/
	
	//{ 1, 25 },
	//{ 0, 125 }
};

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("kek");
	g_Module.ScriptInfo.SetContactInfo("https://github.com/kekekekkek/ExplosiveBullets");
	
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
	g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
	
	g_Hooks.RegisterHook(Hooks::Weapon::WeaponPrimaryAttack, @WeaponPrimaryAttack);
}

array<string> WeaponFilter()
{
	array<string> strWeapons = 
	{
		"weapon_crowbar",
		"weapon_pipewrench",
		"weapon_medkit",
		"weapon_grapple",
		"weapon_rpg",
		"weapon_gauss",
		"weapon_egon",
		"weapon_hornetgun",
		"weapon_handgrenade",
		"weapon_satchel",
		"weapon_tripmine",
		"weapon_snark",
		"weapon_sporelauncher",
		"weapon_displacer"
	};
	
	return strWeapons;
}

bool IsNaN(string strValue)
{
	int iPointCount = 0;

	for (uint i = 0; i < strValue.Length(); i++)
	{
		if (i == 0 && strValue[i] == '-')
			continue;
			
		if (strValue[i] == '.')
		{
			iPointCount++;
		
			if (iPointCount < 2)
				continue;
		}
	
		if (!isdigit(strValue[i]))
			return true;
	}
	
	return false;
}

void ExplosionBullet(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, int iExplosionSize, bool bFilterWeapons, bool bDoDamage = true)
{
    Vector vVecAngles = pPlayer.pev.v_angle;
    Vector vVecEyePos = pPlayer.EyePosition();

    Vector vVecDirection, vVecIntermediate;
    g_EngineFuncs.AngleVectors(vVecAngles, vVecDirection, vVecIntermediate, vVecIntermediate);

	edict_t@ pEdict = pPlayer.edict();
    Vector vVecEndPos = (vVecEyePos + (vVecDirection * Math.INT32_MAX));
	
	TraceResult trResult;
	g_Utility.TraceLine(vVecEyePos, vVecEndPos, dont_ignore_monsters, pEdict, trResult);
	
	if (bFilterWeapons)
	{
		array<string> strGetWeapons = WeaponFilter();
		int iArrayLength = strGetWeapons.length();
	
		for (int i = 0; i < iArrayLength; i++)
		{
			if (pWeapon.pev.classname == strGetWeapons[i]
				|| pWeapon.m_bFireOnEmpty)
					return;
		}
	}
	
	g_EntityFuncs.CreateExplosion(trResult.vecEndPos, Vector(), pEdict, iExplosionSize, bDoDamage);
}

HookReturnCode WeaponPrimaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
{
	int iPlayerIndex = 0;
	int iIdsLength = strSaveIds.length();
	
	string strId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	AdminLevel_t altAdminLevel = g_PlayerFuncs.AdminLevel(pPlayer);

	for (int i = 0; i < iIdsLength; i++)
	{
		if (strId == strSaveIds[i])
		{
			iPlayerIndex = i;
			break;
		}
	}
	
	if (iSaveParams.length() > 0)
	{
		if (!bAdminsOnly || altAdminLevel >= ADMIN_YES)
		{
			if (iSaveParams[iPlayerIndex][0] == 1)
				ExplosionBullet(pPlayer, pWeapon, iSaveParams[iPlayerIndex][1], true);
		}
	}
	
    return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
{
	bool bSkipPlayer = false;

	int iIdsLength = strSaveIds.length();
	int iParamsLength = iSaveParams.length();
	
	string strId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	
	for (int i = 0; i < iIdsLength; i++)
	{
		if (strId == strSaveIds[i])
		{
			bSkipPlayer = true;	
			break;
		}
	}

	if ((iParamsLength <= 0 && iIdsLength <= 0) || !bSkipPlayer)
	{
		iSaveParams.insertAt(iParamsLength, array<int> = { 1, 25 });	
		strSaveIds.insertAt(iIdsLength, strId);
	}
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientSay(SayParameters@ pSayParam)
{
	int iPlayerIndex = -1;
	bool bSkipPlayer = false;

	int iIdsLength = strSaveIds.length();
	int iParamsLength = iSaveParams.length();

	string strMsg = pSayParam.GetCommand();
	int iArgs = pSayParam.GetArguments().ArgC();
	
	CBasePlayer@ pPlayer = pSayParam.GetPlayer();
	string strId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	
	AdminLevel_t altAdminLevel = g_PlayerFuncs.AdminLevel(pPlayer);
	
	for (int i = 0; i < iIdsLength; i++)
	{
		if (strId == strSaveIds[i])
		{
			iPlayerIndex = i;
			bSkipPlayer = true;
			
			break;
		}
	}
	
	if ((iParamsLength <= 0 && iIdsLength <= 0) || !bSkipPlayer)
	{
		iSaveParams.insertAt(iParamsLength, array<int> = { 1, 25 });	
		strSaveIds.insertAt(iIdsLength, strId);
		
		iIdsLength = strSaveIds.length();
		iParamsLength = iSaveParams.length();
		
		ClientSay(pSayParam);
		return HOOK_CONTINUE;
	}
	
	if (iPlayerIndex != -1)
	{
		bool bError = false;
		array<string> strCmd = 
		{
			".ebs", "/ebs", "!ebs",
			".ebm", "/ebm", "!ebm",
			".ebao", "/ebao", "!ebao",
		};
		
		array<string> strDesc =
		{
			"[EBInfo]: Usage: .ebs//ebs/!ebs <state>. Example: !ebs 1\n",
			"[EBInfo]: Usage: .ebm//ebm/!ebm <magnitude>. Example: !ebm 125\n",
			"[EBInfo]: Usage: .ebao//ebao/!ebao <adminsonly>. Example: !ebao 0\n",
		};
		
		if (iArgs == 1)
		{
			int iNum = 0;
		
			for (uint i = 0; i < strCmd.length(); i++)
			{
				if (pSayParam.GetArguments().Arg(0).ToLowercase() == strCmd[i])
				{
					if (i > 0 && i < 3)
						iNum = 0;
						
					if (i > 3 && i < 6)
						iNum = 1;
						
					if (i > 6 && i < 9)
						iNum = 2;
						
					if (iNum != 2 || altAdminLevel >= ADMIN_YES)
						g_PlayerFuncs.SayText(pPlayer, strDesc[iNum]);
					else
						g_PlayerFuncs.SayText(pPlayer, "[EBError]: This command is for admins only.\n");
					
					pSayParam.ShouldHide = true;
					return HOOK_HANDLED;
				}
			}
			
			if (pSayParam.GetArguments().Arg(0).ToLowercase() == ".ebr"
				|| pSayParam.GetArguments().Arg(0).ToLowercase() == "/ebr"
				|| pSayParam.GetArguments().Arg(0).ToLowercase() == "!ebr")
			{
				iSaveParams[iPlayerIndex][0] = 1;
				iSaveParams[iPlayerIndex][1] = 25;
				
				g_PlayerFuncs.SayText(pPlayer, "[EBSuccess]: All settings of the explosive bullet have been reset to the default values.\n");
				
				pSayParam.ShouldHide = true;
				return HOOK_HANDLED;
			}
		}
		
		if (iArgs == 2)
		{
			string strArg = pSayParam.GetArguments().Arg(1);
			
			if (pSayParam.GetArguments().Arg(0).ToLowercase() == ".ebao"
				|| pSayParam.GetArguments().Arg(0).ToLowercase() == "/ebao"
				|| pSayParam.GetArguments().Arg(0).ToLowercase() == "!ebao")
			{
				if (altAdminLevel >= ADMIN_YES)
				{
					if (IsNaN(strArg))
					{
						g_PlayerFuncs.SayText(pPlayer, "[EBError]: The argument is not a number!\n");
						bError = true;
					}
					
					if (!bError)
					{
						(atoi(strArg) >= 1 ? bAdminsOnly = true : bAdminsOnly = false);				
						g_PlayerFuncs.SayTextAll(pPlayer, (bAdminsOnly == true
							? "[EBInfo]: The explosive bullets function is now available only for admins.\n" 
							: "[EBInfo]: The explosive bullets function is now available to everyone!\n"));
					}
					
					pSayParam.ShouldHide = true;
					return HOOK_HANDLED;
				}
				else
				{
					g_PlayerFuncs.SayText(pPlayer, "[EBError]: This command is for admins only.\n");
				
					pSayParam.ShouldHide = true;
					return HOOK_HANDLED;
				}
			}
		
			if (pSayParam.GetArguments().Arg(0).ToLowercase() == ".ebs"
				|| pSayParam.GetArguments().Arg(0).ToLowercase() == "/ebs"
				|| pSayParam.GetArguments().Arg(0).ToLowercase() == "!ebs")
			{
				if (IsNaN(strArg))
				{
					g_PlayerFuncs.SayText(pPlayer, "[EBError]: The argument is not a number!\n");
					bError = true;
				}
				
				if (!bError)
				{
					int iState = int(Math.clamp(0, 1, atoi(strArg)));
					iSaveParams[iPlayerIndex][0] = iState;
					
					g_PlayerFuncs.SayText(pPlayer, (iState == 1
						? "[EBSuccess]: The explosive bullets function was enabled!\n" 
						: "[EBSuccess]: The explosive bullets function was disabled!\n"));
				}
				
				pSayParam.ShouldHide = true;
				return HOOK_HANDLED;
			}
			
			if (pSayParam.GetArguments().Arg(0).ToLowercase() == ".ebm"
				|| pSayParam.GetArguments().Arg(0).ToLowercase() == "/ebm"
				|| pSayParam.GetArguments().Arg(0).ToLowercase() == "!ebm")
			{
				int iMagnitude = 0;
			
				if (IsNaN(strArg))
				{
					g_PlayerFuncs.SayText(pPlayer, "[EBError]: The argument is not a number!\n");
					bError = true;
				}
				
				if (!bError)
					iMagnitude = int(atoi(strArg));
				
				if (!bError)
				{
					if (iMagnitude < 25 || iMagnitude > 5000)
					{
						g_PlayerFuncs.SayText(pPlayer, "[EBError]: The magnitude of the explosion should be between 25 and 5000!\n");
						bError = true;
					}
				}
				
				if (!bError)
				{
					iSaveParams[iPlayerIndex][1] = iMagnitude;
					
					if (iMagnitude >= 1000)
						g_PlayerFuncs.SayText(pPlayer, "[EBSuccess]: The magnitude of the explosion has been successfully changed! Are you really crazy? xd\n");
					else
						g_PlayerFuncs.SayText(pPlayer, "[EBSuccess]: The magnitude of the explosion has been successfully changed!\n");
				}
				
				pSayParam.ShouldHide = true;
				return HOOK_HANDLED;
			}
		}
	}
	
	return HOOK_CONTINUE;
}