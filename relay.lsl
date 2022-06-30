integer c = 1374922;
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
    llListen(c,"","",""); 
    }
    listen(integer c,string n, key i, string m)
    { 
    list items = llParseString2List(m, ["="], []); 
    if(llGetOwnerKey(i)==llGetOwner())
    {
         if (llList2String(items,0) == "banned")
         { 
         llAddToLandBanList(llList2Key(items,1),0);
         return;
         }
         if (llList2String(items,0) == "unbanned")
         { 
         llRemoveFromLandBanList(llList2Key(items,1));
         return;
         }
      }  
   }
} 
