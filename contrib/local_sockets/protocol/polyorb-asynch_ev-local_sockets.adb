------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--      P O L Y O R B . A S Y N C H _ E V . L O C A L _ S O C K E T S       --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--            Copyright (C) 2005 Free Software Foundation, Inc.             --
--                                                                          --
-- PolyORB is free software; you  can  redistribute  it and/or modify it    --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. PolyORB is distributed  in the hope that it will be  useful,    --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with PolyORB; see file COPYING. If    --
-- not, write to the Free Software Foundation, 51 Franklin Street, Fifth    --
-- Floor, Boston, MA 02111-1301, USA.                                       --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
--                                                                          --
--                  PolyORB is maintained by AdaCore                        --
--                     (email: sales@adacore.com)                           --
--                                                                          --
------------------------------------------------------------------------------

with PolyORB.Utils.Chained_Lists;
with PolyORB.Log;

package body PolyORB.Asynch_Ev.Local_Sockets is

   use PolyORB.Log;
   use PolyORB.Local_Sockets;

   package L is new PolyORB.Log.Facility_Log
     ("polyorb.asynch_ev.local_sockets");
   procedure O (Message : in String; Level : Log_Level := Debug)
     renames L.Output;
   function C (Level : Log_Level := Debug) return Boolean
     renames L.Enabled;
   pragma Unreferenced (C); --  For conditional pragma Debug

   ------------
   -- Create --
   ------------

   procedure Create (AEM : out Local_Event_Monitor) is
   begin
      Empty (AEM.Monitored_Set);
      Create_Selector (AEM.Selector);
   end Create;

   -------------
   -- Destroy --
   -------------

   procedure Destroy (AEM : in out Local_Event_Monitor) is
   begin
      Empty (AEM.Monitored_Set);
      Close_Selector (AEM.Selector);
   end Destroy;

   ---------------------
   -- Register_Source --
   ---------------------

   procedure Register_Source
     (AEM     : access Local_Event_Monitor;
      AES     : Asynch_Ev_Source_Access;
      Success : out Boolean)
   is
   begin
      pragma Debug (O ("Register_Source: enter"));

      Success := False;
      if AES.all not  in Local_Event_Source then
         pragma Debug (O ("Register_Source: leave"));
         return;
      end if;

      Set (AEM.Monitored_Set, Local_Event_Source (AES.all).Socket);
      Source_Lists.Append (AEM.Sources, AES);
      pragma Debug
        (O ("Register_Source: Sources'Length:=" &
             Integer'Image (Source_Lists.Length (AEM.Sources))));
      AES.Monitor := Asynch_Ev_Monitor_Access (AEM);

      Success := True;
      pragma Debug (O ("Register_Source: leave"));
   end Register_Source;

   -----------------------
   -- Unregister_Source --
   -----------------------

   procedure Unregister_Source
     (AEM : in out Local_Event_Monitor;
      AES : Asynch_Ev_Source_Access)
   is
   begin
      pragma Debug (O ("Unregister_Source: enter"));
      Clear (AEM.Monitored_Set, Local_Event_Source (AES.all).Socket);
      Source_Lists.Remove (AEM.Sources, AES);
      pragma Debug
        (O ("Unregister_Source: Sources'Length:=" &
             Integer'Image (Source_Lists.Length (AEM.Sources))));
      pragma Debug (O ("Unregister_Source: leave"));
   end Unregister_Source;

   -------------------
   -- Check_Sources --
   -------------------

   function Check_Sources
     (AEM     : access Local_Event_Monitor;
      Timeout : Duration)
      return    AES_Array
   is
      use Source_Lists;

      Result : AES_Array (1 .. Length (AEM.Sources));
      Last   : Integer := 0;

      T : constant Duration := Timeout;
      --  XXX questionnable

      R_Set  : Local_Socket_Set_Type;
      Status : Selector_Status;

   begin
      pragma Debug (O ("Check_Sources: enter"));

      Copy (Source => AEM.Monitored_Set, Target => R_Set);
      pragma Debug (O (Integer'Image (Source_Lists.Length (AEM.Sources))));

      Check_Selector
        (Selector     => AEM.Selector,
         R_Socket_Set => R_Set,
         Status       => Status,
         Timeout      => T);

      pragma Debug
        (O ("Selector returned status " & Selector_Status'Image (Status)));

      if Status = Completed then
         declare
            It : Source_Lists.Iterator := First (AEM.Sources);
         begin
            while not Source_Lists.Last (It) loop
               pragma Debug (O ("Iterate over source list"));

               declare
                  S    : Asynch_Ev_Source_Access renames Value (It).all;
                  Sock : Local_Socket_Access renames
                    Local_Event_Source (S.all).Socket;
               begin
                  if Is_Set (R_Set, Sock) then
                     Last          := Last + 1;
                     Result (Last) := S;

                     Clear (AEM.Monitored_Set, Sock);
                     Remove (AEM.Sources, It);
                  else
                     Next (It);
                  end if;
               end;
            end loop;
         end;
         pragma Assert (Last >= Result'First);
      end if;

      --  Free the storage space associated with our socket sets.

      PolyORB.Local_Sockets.Empty (R_Set);

      pragma Debug (O ("Check_Sources: end"));

      return Result (1 .. Last);
   end Check_Sources;

   -------------------------
   -- Abort_Check_Sources --
   -------------------------

   procedure Abort_Check_Sources (AEM : Local_Event_Monitor) is
   begin
      Abort_Selector (AEM.Selector);
   end Abort_Check_Sources;

   -------------------------
   -- Create_Event_Source --
   -------------------------

   function Create_Event_Source
     (Socket : PolyORB.Local_Sockets.Local_Socket_Access)
      return   Asynch_Ev_Source_Access
   is
      Result : constant Asynch_Ev_Source_Access := new Local_Event_Source;

   begin
      Local_Event_Source (Result.all).Socket := Socket;
      return Result;
   end Create_Event_Source;

   -------------------------------
   -- Create_Local_Event_Monitor --
   -------------------------------

   function Create_Local_Event_Monitor return Asynch_Ev_Monitor_Access;

   function Create_Local_Event_Monitor return Asynch_Ev_Monitor_Access is
   begin
      return new Local_Event_Monitor;
   end Create_Local_Event_Monitor;

   --------------------
   -- AEM_Factory_Of --
   --------------------

   function AEM_Factory_Of (AES : Local_Event_Source) return AEM_Factory is
      pragma Warnings (Off);
      pragma Unreferenced (AES);
      pragma Warnings (On);

   begin
      return Create_Local_Event_Monitor'Access;
   end AEM_Factory_Of;

end PolyORB.Asynch_Ev.Local_Sockets;
