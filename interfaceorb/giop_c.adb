-----------------------------------------------------------------------
-----------------------------------------------------------------------
----                                                               ----
----                         AdaBroker                             ----
----                                                               ----
----                       package Giop_s                          ----
----                                                               ----
----                                                               ----
----   Copyright (C) 1999 ENST                                     ----
----                                                               ----
----   This file is part of the AdaBroker library                  ----
----                                                               ----
----   The AdaBroker library is free software; you can             ----
----   redistribute it and/or modify it under the terms of the     ----
----   GNU Library General Public License as published by the      ----
----   Free Software Foundation; either version 2 of the License,  ----
----   or (at your option) any later version.                      ----
----                                                               ----
----   This library is distributed in the hope that it will be     ----
----   useful, but WITHOUT ANY WARRANTY; without even the implied  ----
----   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ----
----   PURPOSE.  See the GNU Library General Public License for    ----
----   more details.                                               ----
----                                                               ----
----   You should have received a copy of the GNU Library General  ----
----   Public License along with this library; if not, write to    ----
----   the Free Software Foundation, Inc., 59 Temple Place -       ----
----   Suite 330, Boston, MA 02111-1307, USA                       ----
----                                                               ----
----                                                               ----
----                                                               ----
----   Description                                                 ----
----   -----------                                                 ----
----                                                               ----
----     This package is wrapped around the C++ class              ----
----   Ada_Giop_s declared in Ada_Giop_s.hh.                       ----
----     It provides the same functions as this package plus       ----
----   the Ada version of thouse where arguments types are         ----
----   to be change.                                               ----
----     It does not include an Init function since it is          ----
----   useless for AdaBroker. (AdaBroker never creates a Giop_s    ----
----   object)                                                     ----
----                                                               ----
----                                                               ----
----   authors : Sebastien Ponce, Fabien Azavant                   ----
----   date    : 02/28/99                                          ----
----                                                               ----
-----------------------------------------------------------------------
-----------------------------------------------------------------------


with Ada.Unchecked_Conversion ;
with Ada.Exceptions ;
with Ada.Strings.Unbounded ;

with Corba ;
use type Corba.Unsigned_Long ;

with Adabroker_Debug ; use Adabroker_Debug ;

package body Giop_C is


   -- C_Init
   ---------
   procedure C_Init (Self : in out Object'Class ;
                     R : in System.Address) ;
   pragma Import (C,C_Init,"Init__10Ada_Giop_cP4Rope") ;
   -- wrapper around  Ada_Giop_c procedure Init
   -- (see Ada_Giop_c.hh)
   -- called by the Ada equivalent : Init


   -- Init
   -------
   procedure Init (Self : in out Object'Class ;
                   R : in Rope.Object) is
   begin
      pragma Debug(Output(Debug, "--- giop_c.Init ---"))  ;
      pragma Debug(Output(Debug, "init_Ok = " & Boolean'Image(Sys_Dep.Boolean_C_To_Ada(Self.Init_Ok))))  ;
      -- just calls the C procedure
      C_Init (Self, System.Address (R)) ;
   end;


   -- Ada_To_C_Unsigned_Long
   -------------------------
   function Ada_To_C_Unsigned_Long is
     new Ada.Unchecked_Conversion (Corba.Unsigned_Long,
                                   Interfaces.C.Unsigned_Long) ;
   -- needed to change ada type Corba.Unsigned_Long
   -- into C type Interfaces.C.Unsigned_Long


   -- C_Initialize_Request
   -----------------------
   procedure C_Initialize_Request (Self : in Object'Class ;
                                   Objkey : in System.Address ;
                                   Objkeysize : in Interfaces.C.Unsigned_Long ;
                                   Opname : in Interfaces.C.Strings.Chars_Ptr ;
                                   Opnamesize : in Interfaces.C.Unsigned_Long ;
                                   MsgSize : in Interfaces.C.Unsigned_Long ;
                                   Oneway : in Sys_Dep.C_Boolean) ;
   pragma Import (C,C_Initialize_Request,"InitialiseRequest__10Ada_Giop_cPCvUiPCcUiUib") ;
   -- wrapper around  Ada_Giop_c procedure Initialize_Request
   -- (see Ada_Giop_c.hh)
   -- called by the Ada equivalent : Initialize_Request


   -- Initialize_Request
   ---------------------
   procedure Initialize_Request (Self : in Object'Class ;
                                 Objkey : in Corba.Octet ;
                                 Objkeysize : in Corba.Unsigned_Long ;
                                 Opname : in Corba.String ;
                                 MsgSize : in Corba.Unsigned_Long ;
                                 Oneway : in Corba.Boolean) is
      C_Objkey : System.Address ;
      C_Objkeysize : Interfaces.C.Unsigned_Long ;
      Ada_Opname : String := Ada.Strings.Unbounded.To_String (Ada.Strings.Unbounded.Unbounded_String (Opname)) ;
      C_Opname : Interfaces.C.Strings.Chars_Ptr ;
      C_OpnameSize : Interfaces.C.Unsigned_Long ;
      C_MsgSize : Interfaces.C.Unsigned_Long ;
      C_Oneway : Sys_Dep.C_Boolean ;
   begin
      -- transforms the arguments into a C type ...
      C_Objkey := Objkey'Address ;
      C_Objkeysize := Ada_To_C_Unsigned_Long (Objkeysize) ;
      C_Opname := Interfaces.C.Strings.New_String (Ada_Opname) ;
      -- desallocation in a few lines
      C_Opnamesize := Ada_To_C_Unsigned_Long (Corba.Length (Opname)
                                              + Corba.Unsigned_Long (1)) ;
      C_MsgSize := Ada_To_C_Unsigned_Long (MsgSize) ;
      C_Oneway := Sys_Dep.Boolean_Ada_To_C (Oneway) ;
      -- ... and calls the C procedure
      C_Initialize_Request (Self,
                            C_Objkey,
                            C_Objkeysize,
                            C_Opname,
                            C_Opnamesize,
                            C_MsgSize,
                            C_Oneway) ;
      -- desallocation of C_Opname
      Interfaces.C.Strings.Free (C_Opname) ;
   end ;


   -- C_Receive_Reply
   ------------------
   function C_Receive_Reply (Self : in Object'Class)
                             return Interfaces.C.Int ;
   pragma Import (C,C_Receive_Reply,"ReceiveReply__10Ada_Giop_c") ;
   -- wrapper around  Ada_Giop_c procedure Receive_Reply
   -- (see Ada_Giop_c.hh)
   -- called by the Ada equivalent : Receive_Reply


   -- Receive_Reply
   ----------------
   function Receive_Reply (Self : in Object'Class)
                           return Giop.Reply_Status_Type is
      C_Result : Interfaces.C.Int ;
   begin
      -- calls the C function ...
      C_Result := C_Receive_Reply (Self) ;
      -- ... and transforms the result into an Ada type
      return Giop.C_Int_To_Reply_Status_Type (C_Result) ;
   end;


   -- C_Request_Completed
   ----------------------
   procedure C_Request_Completed (Self : in Object'Class ;
                                  Skip_Msg : in Sys_Dep.C_Boolean) ;
   pragma Import (C,C_Request_Completed,"RequestCompleted__10Ada_Giop_cb") ;
   -- wrapper around  Ada_Giop_c procedure Request_Completed
   -- (see Ada_Giop_c.hh)
   -- called by the Ada equivalent : Request_Completed


   -- Request_Completed
   --------------------
   procedure Request_Completed (Self : in Object'Class ;
                                Skip_Msg : in CORBA.Boolean := False) is
      C_Skip_Msg : Sys_Dep.C_Boolean ;
   begin
      -- transforms the arguments into a C type ...
      C_Skip_Msg := Sys_Dep.Boolean_Ada_To_C (Skip_Msg) ;
      -- ... and calls the C procedure
      C_Request_Completed (Self, C_Skip_Msg) ;
   end ;


   -- C_To_Ada_Unsigned_Long
   -------------------------
   function C_To_Ada_Unsigned_Long is
     new Ada.Unchecked_Conversion (Interfaces.C.Unsigned_Long,
                                   Corba.Unsigned_Long) ;
   -- needed to change C type Interfaces.C.Unsigned_Long
   -- into ada type Corba.Unsigned_Long


   -- C_Request_Header_Size
   ------------------------
   function C_Request_Header_Size (Objkeysize : in Interfaces.C.Unsigned_long ;
                                   Opnamesize : in Interfaces.C.Unsigned_long)
                                   return Interfaces.C.Unsigned_long ;
   pragma Import (C,C_Request_Header_Size,"RequestHeaderSize__6GIOP_CUiUi") ;
   -- wrapper around GIOP_C procedure Request_Header_Size
   -- (see giopDriver.h)
   -- called by the Ada equivalent : Request_Header_Size


   -- Request_Header_Size
   ----------------------
   function Request_Header_Size (Objkeysize : in Corba.Unsigned_long ;
                                 Opnamesize : in Corba.Unsigned_long)
                                 return Corba.Unsigned_long is
      C_Objkeysize : Interfaces.C.Unsigned_Long ;
      C_Opnamesize : Interfaces.C.Unsigned_Long ;
      C_Result : Interfaces.C.Unsigned_Long ;
   begin
      -- transforms the arguments into a C type ...
      C_Objkeysize := Ada_To_C_Unsigned_Long (Objkeysize) ;
      C_Opnamesize := Ada_To_C_Unsigned_Long (Opnamesize) ;
      -- ... calls the C procedure ...
      C_Result := C_Request_Header_Size (C_Objkeysize, C_Opnamesize) ;
      -- ... and transforms the result into an Ada type
      return  C_To_Ada_Unsigned_Long (C_Result) ;
   end;

end Giop_C ;

