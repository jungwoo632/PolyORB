------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                   A D A _ B E . T E M P O R A R I E S                    --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--            Copyright (C) 2004 Free Software Foundation, Inc.             --
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

with Idlac_Flags;

package body Ada_Be.Temporaries is

   use Idlac_Flags;

   function Suffix return String;
   --  Return the suffix value for the current encoding setting.

   type String_Access is access String;

   --  To avoid collisions between identifiers generated by idlac and
   --  identifiers resulting from the mapping of IDL user identifiers,
   --  one non-ASCII character is appended to the former
   --  (now LATIN CAPITAL LETTER U WITH DIAERESIS), since such characters
   --  are not permitted in IDL identifiers.
   --  This table encodes the representation of that character in different
   --  character sets.

   Suffix_Table : constant array (Encoding) of String_Access
     := (ISO_Latin_1 => new String'(1 => Character'Val (16#DC#)),
         UTF_8       => new String'(1 => Character'Val (16#C3#),
                                    2 => Character'Val (16#9C#)));

   ------------
   -- Suffix --
   ------------

   function Suffix return String is
   begin
      return Suffix_Table (Character_Encoding).all;
   end Suffix;

   ----------------
   -- T_Argument --
   ----------------

   function T_Argument return String is
   begin
      return "Argument_" & Suffix & '_';
   end T_Argument;

   ----------------
   -- T_Arg_List --
   ----------------

   function T_Arg_List return String is
   begin
      return "Arg_List_" & Suffix;
   end T_Arg_List;

   ----------------
   -- T_Arg_Name --
   ----------------

   function T_Arg_Name return String is
   begin
      return "Arg_Name_" & Suffix & '_';
   end T_Arg_Name;

   -------------------------
   -- T_Exception_Repo_Id --
   -------------------------

   function T_Exception_Repo_Id return String is
   begin
      return "Exception_Repo_Id_" & Suffix;
   end T_Exception_Repo_Id;

   -----------------
   -- T_Excp_List --
   -----------------

   function T_Excp_List return String is
   begin
      return "Excp_List_" & Suffix;
   end T_Excp_List;

   -----------
   -- T_Ctx --
   -----------

   function T_Ctx return String is
   begin
      return "Ctx_" & Suffix;
   end T_Ctx;

   ---------------
   -- T_Handler --
   ---------------

   function T_Handler return String is
   begin
      return "Handler_" & Suffix;
   end T_Handler;

   -----------------------
   -- T_Impl_Object_Ptr --
   -----------------------

   function T_Impl_Object_Ptr return String is
   begin
      return "Object_" & Suffix;
   end T_Impl_Object_Ptr;

   ---------
   -- T_J --
   ---------

   function T_J return String is
   begin
      return "J_" & Suffix;
   end T_J;

   ---------------
   -- T_Members --
   ---------------

   function T_Members return String is
   begin
      return "Members_" & Suffix;
   end T_Members;

   ----------------------
   -- T_Operation_Name --
   ----------------------

   function T_Operation_Name return String is
   begin
      return "Operation_Name_" & Suffix;
   end T_Operation_Name;

   ---------------
   -- T_Request --
   ---------------

   function T_Request return String is
   begin
      return "Request_" & Suffix;
   end T_Request;

   --------------
   -- T_Result --
   --------------

   function T_Result return String is
   begin
      return "Result_" & Suffix;
   end T_Result;

   -------------------
   -- T_Result_Name --
   -------------------

   function T_Result_Name return String is
   begin
      return "Result_Name_" & Suffix;
   end T_Result_Name;

   ---------------
   -- T_Returns --
   ---------------

   function T_Returns return String is
   begin
      return "Return_" & Suffix;
   end T_Returns;

   ----------------
   -- T_Self_Ref --
   ----------------

   function T_Self_Ref return String is
   begin
      return "Self_Ref_" & Suffix;
   end T_Self_Ref;

   ---------------------------
   -- T_Send_Request_Result --
   ---------------------------

   function T_Send_Request_Result return String is
   begin
      return "Send_Request_Result_" & Suffix;
   end T_Send_Request_Result;

   -----------------------
   -- T_Value_Operation --
   -----------------------

   function T_Value_Operation return String is
   begin
      return "Op_" & Suffix;
   end T_Value_Operation;

end Ada_Be.Temporaries;
