/*
Alright, it's been a while since I've done this. Let's see if I can remember how to start this off.
Thanks to comp sci courses I'm actually gonna properly document everything in this.
It won't be up to standards, but it'll at least be something that makes the code more readable than my old plugins. 

Creator: Zethax
Document created: Monday, December 17th 2018
Last edit: Monday, December 17th, 2018

*/

#pragma semicolon 1
#include <sourcemod>
#include <tf2>
#include <zethax>
#include <cw3>
#include <sdktools>
#include <sdkhooks>

/*
=================
|               |
|   I N P U T   |
|               |
=================
*/

//Not sure if defining variables would go here, so just gonna roll with it. 

public Action:CW3_OnAddAttribute()
{
  new Action:action;
  
  if(strEqual(attrib, "something"))
  {
    
    action = Plugin_Handled;
  }
  
  return action;
}

/*
===========================
|                         |
|   P R O C E S S I N G   |
|                         |
===========================
*/

/*
===================
|                 |
|   O U T P U T   |
|                 |
===================
*/
