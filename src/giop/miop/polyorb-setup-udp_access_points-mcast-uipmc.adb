------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--               POLYORB.SETUP.UDP_ACCESS_POINTS.MCAST.UIPMC                --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--            Copyright (C) 2003 Free Software Foundation, Inc.             --
--                                                                          --
-- PolyORB is free software; you  can  redistribute  it and/or modify it    --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. PolyORB is distributed  in the hope that it will be  useful,    --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with PolyORB; see file COPYING. If    --
-- not, write to the Free Software Foundation, 59 Temple Place - Suite 330, --
-- Boston, MA 02111-1307, USA.                                              --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
--                                                                          --
--                PolyORB is maintained by ACT Europe.                      --
--                    (email: sales@act-europe.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

--  Setup socket for UIPMC

with PolyORB.Binding_Data.UIPMC;
with PolyORB.Configuration;
with PolyORB.Filters;
with PolyORB.Filters.Fragmenter;
with PolyORB.Filters.MIOP.MIOP_In;
with PolyORB.Initialization;
pragma Elaborate_All (PolyORB.Initialization); --  WAG:3.15
with PolyORB.ORB;
with PolyORB.Protocols;
with PolyORB.Protocols.GIOP.UIPMC;
with PolyORB.Transport.Datagram.Sockets_In;
with PolyORB.Utils.Strings;

package body PolyORB.Setup.UDP_Access_Points.MCast.UIPMC is

   use PolyORB.Filters;
   use PolyORB.Filters.Fragmenter;
   use PolyORB.Filters.MIOP.MIOP_In;
   use PolyORB.ORB;
   use PolyORB.Transport.Datagram.Sockets_In;

   UIPMC_Access_Point : UDP_Access_Point_Info
     := (Socket  => No_Socket,
         Address => No_Sock_Addr,
         SAP     => new Socket_In_Access_Point,
         PF      => new Binding_Data.UIPMC.UIPMC_Profile_Factory);

   UIPMC_Pro : aliased Protocols.GIOP.UIPMC.UIPMC_Protocol;
   M_Fact    : aliased MIOP_In_Factory;
   Frag      : aliased Fragmenter_Factory;

   ------------------------------
   -- Initialize_Access_Points --
   ------------------------------

   procedure Initialize_Access_Points;

   procedure Initialize_Access_Points
   is
      use PolyORB.Configuration;

      Addr : constant String
        := Get_Conf
        ("miop", "polyorb.miop.multicast_addr",
         Default_Multicast_Group);
      Port : constant Port_Type
        := Port_Type (Get_Conf
                      ("miop", "polyorb.miop.multicast_port",
                       Default_Port));
   begin
      if Get_Conf ("access_points", "uipmc", True) then


         Initialize_MCast
           (UIPMC_Access_Point, Inet_Addr (Addr), Port);

         Chain_Factories ((0 => Frag'Unchecked_Access,
                           1 => M_Fact'Unchecked_Access,
                           2 => UIPMC_Pro'Unchecked_Access));

         Register_Access_Point
           (ORB    => The_ORB,
            TAP    => UIPMC_Access_Point.SAP,
            Chain  => Frag'Unchecked_Access,
            PF     => UIPMC_Access_Point.PF);
      end if;

   end Initialize_Access_Points;

   use PolyORB.Initialization;
   use PolyORB.Initialization.String_Lists;
   use PolyORB.Utils.Strings;

begin
   Register_Module
     (Module_Info'
      (Name      => +"mcast_access_points.corba",
       Conflicts => String_Lists.Empty,
       Depends   => +"orb" & "sockets",
       Provides  => String_Lists.Empty,
       Init      => Initialize_Access_Points'Access));

end PolyORB.Setup.UDP_Access_Points.MCast.UIPMC;
