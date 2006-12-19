------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--      P O L Y O R B . S O A P _ P . M E S S A G E . R E S P O N S E       --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2000-2006, Free Software Foundation, Inc.          --
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

with AWS.MIME;

with PolyORB.SOAP_P.Message.XML;

package body PolyORB.SOAP_P.Message.Response is

   -----------
   -- Build --
   -----------

   function Build (R : Object'Class) return PolyORB.SOAP_P.Response.Data is
   begin
      return PolyORB.SOAP_P.Response.Build
        (AWS.MIME.Text_XML, String'(PolyORB.SOAP_P.Message.XML.Image (R)));
   end Build;

   ----------
   -- From --
   ----------

   function From (P : Message.Payload.Object) return Object is
      NP : Object;
   begin
      Set_Wrapper_Name (NP, Payload.Procedure_Name (P) & "Response");

      Set_Parameters   (NP, Parameters (P));

      Set_Name_Space (NP, Name_Space (P));

      return NP;
   end From;

   --------------
   -- Is_Error --
   --------------

   function Is_Error (R : Object) return Boolean
   is
      pragma Warnings (Off);
      pragma Unreferenced (R);
      pragma Warnings (On);
   begin
      return False;
   end Is_Error;

end PolyORB.SOAP_P.Message.Response;
