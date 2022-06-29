string WEBHOOK_URL = "discord_webhook";
integer verified0 = FALSE;
integer verified1 = FALSE;
integer access = FALSE;
integer timeout = 20;
string authentication;
string url;
key keyurl;
list logs;
webhook_send(string Message,string description) 
{
     string WEBHOOK_name = llDeleteSubString(llGetRegionName(),50, 100); 
     list json = [ 
     "username",WEBHOOK_name+"","embeds", llList2Json(JSON_ARRAY,[
     llList2Json(JSON_OBJECT,["color","100000","title","",
     "description",description,"url","",
     "author", llList2Json(JSON_OBJECT,[ "name",Message,"icon_url",""]),
     "footer", llList2Json(JSON_OBJECT,[ "icon_url",""])                
     ])]),"avatar_url",""];

     key http_request_id = llHTTPRequest(WEBHOOK_URL,[HTTP_METHOD,"POST",HTTP_MIMETYPE,
     "application/json",HTTP_VERIFY_CERT, TRUE,HTTP_VERBOSE_THROTTLE,TRUE,
     HTTP_PRAGMA_NO_CACHE,TRUE],llList2Json(JSON_OBJECT,json));
}
string AgentInfo(key avatar)
{ 
   if(llGetAgentInfo(avatar) & AGENT_ON_OBJECT)  return "sitting on object";
   if(llGetAgentInfo(avatar) & AGENT_AWAY)  return "afk";
   if(llGetAgentInfo(avatar) & AGENT_BUSY)  return "busy";
   if(llGetAgentInfo(avatar) & AGENT_CROUCHING)  return "crouching";
   if(llGetAgentInfo(avatar) & AGENT_FLYING)  return "flying";
   if(llGetAgentInfo(avatar) & AGENT_IN_AIR)  return "in air";
   if(llGetAgentInfo(avatar) & AGENT_MOUSELOOK)  return "mouse look";
   if(llGetAgentInfo(avatar) & AGENT_SITTING)  return "sitting";
   if(llGetAgentInfo(avatar) & AGENT_TYPING)  return "typing";
   if(llGetAgentInfo(avatar) & AGENT_WALKING)  return "walking";     
   if(llGetAgentInfo(avatar) & AGENT_ALWAYS_RUN)  return "running";
   return "standing";
}
lookforagent() 
{
        list List = llGetAgentList(AGENT_LIST_REGION, []);
        integer Length = llGetListLength(List);      
        if (!Length)
        {
        return;
        }
        else
        {
            integer x;
            for ( ; x < Length; x += 1)
            {
            list details = llGetObjectDetails(llList2Key(List, x), ([OBJECT_NAME,OBJECT_POS]));
            vector ovF = llList2Vector(details,1); float a = ovF.x; float b = ovF.y; float c = ovF.z;
            string position = "position : "+ (string)((integer)a)+", "+(string)((integer)b)+", "+(string)((integer)c);
            logs += (list)llList2String(details,0)+"\n"+"uuid : "+llList2String(List, x)+"\n"+" "+position+" Status : "+AgentInfo(llList2Key(List, x))+"\n"+"\n";
            }
      }
}
string valid_id(string uuid)
{ 
if((key)uuid)return "valid "+uuid;
return"invalid "+uuid;
}
random()
{
    verified0 = FALSE;
    verified1 = FALSE;
    access = FALSE;
    llSetTimerEvent(0);
    string generate_code = 
    (string)((integer)llFrand(9))+
    (string)((integer)llFrand(9))+
    (string)((integer)llFrand(9))+
    (string)((integer)llFrand(9))+
    (string)((integer)llFrand(9));
    authentication = generate_code;
}
default
{
    on_rez(integer start_param) 
    {
    llResetScript();
    }
    changed(integer change)
    {
        if (change & CHANGED_REGION_START)         
        {
        llResetScript();
        }
    }
    state_entry()
    {
    random();
    keyurl = llRequestURL();
    }
    http_request(key id, string method, string body)
    {
    list items = llParseString2List(body, ["="], []);
    if ((method == URL_REQUEST_GRANTED) && (id == keyurl) )
    {
    webhook_send("url",(string)body); 
    url = body; keyurl = NULL_KEY;
    }
    else if (method == "POST")
    {
                if (body == "authentication=random")
                {
                    if(verified0 == FALSE)
                    {
                    llHTTPResponse(id,200,"sending code");
                    string generate_code = 
                    (string)((integer)llFrand(9))+
                    (string)((integer)llFrand(9))+
                    (string)((integer)llFrand(9))+
                    (string)((integer)llFrand(9))+
                    (string)((integer)llFrand(9));
                    webhook_send("verification code",generate_code);
                    authentication = generate_code;
                    llSetTimerEvent(timeout);
                    verified0 = FALSE;
                    verified1 = TRUE;
                    return;
                    }
                }
                if(verified1 == TRUE)
                { 
                    if (llList2String(items,1) == authentication)
                    {
                    llHTTPResponse(id,200,"access granted");
                    verified0 = TRUE;
                    verified1 = FALSE;
                    access = TRUE;
                    return;
                    }
             }
      }
      if(access == TRUE)
      {
             if (body == "scan=avatar")
             {  
                 lookforagent();
                 webhook_send("Avatar_Scan",(string)logs);
                 llHTTPResponse(id,200,"scan complete");
                 logs = [];
                 random();
                 return;
             }
             if (llList2String(items,0) == "kick")
             {
                 llHTTPResponse(id,200,valid_id(llList2Key(items,1)));
                 llTeleportAgentHome(llList2Key(items,1));
                 random();
                 return;
             }
             if (llList2String(items,0) == "banned")
             {
                 llHTTPResponse(id,200,valid_id(llList2Key(items,1)));
                 llTeleportAgentHome(llList2Key(items,1));
                 llAddToLandBanList(llList2Key(items,1),0);
                 random();
                 return;  
             }
             if (llList2String(items,0) == "unbanned")
             {
                 llHTTPResponse(id,200,valid_id(llList2Key(items,1)));
                 llRemoveFromLandBanList(llList2Key(items,1));
                 random();
                 return;
             }    
      }
      else
      {     
      llHTTPResponse(id,200,"authority denied");
      random();
      return;
      }
}
timer()
{
    random();
    }
}
