--  $Id$

package body Droopi.ORB.Task_Policies is

   use Droopi.Sockets;

   procedure Handle_New_Connection
     (P   : access No_Tasking;
      ORB : ORB_Access;
      AS  : Active_Socket) is
   begin
      Insert_Socket (ORB, AS);
      --  The newly-created channel will be monitored
      --  by general-purpose ORB tasks.
   end;

   procedure Handle_Request
     (P   : access No_Tasking;
      ORB : ORB_Access;
      R   : Droopi.Requests.Request) is
   begin
      --  J := Create_Job_For_Request (R);
      --  Schedule_Job (J);
      raise Not_Implemented;
   end;

end Droopi.ORB.Task_Policies;
