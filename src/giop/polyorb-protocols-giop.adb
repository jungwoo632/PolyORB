------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--               P O L Y O R B . P R O T O C O L S . G I O P                --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2002-2003 Free Software Foundation, Inc.           --
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

with Ada.Streams;

with PolyORB.Annotations;
with PolyORB.Binding_Data;
with PolyORB.Buffers;
with PolyORB.Components;
with PolyORB.GIOP_P.Exceptions;
with PolyORB.Log;
with PolyORB.ORB;
with PolyORB.Parameters;
with PolyORB.References;
with PolyORB.Representations.CDR;
with PolyORB.Types;

package body PolyORB.Protocols.GIOP is

   use PolyORB.Annotations;
   use PolyORB.Buffers;
   use PolyORB.Components;
   use PolyORB.Log;
   use PolyORB.ORB;
   use PolyORB.Representations.CDR;
   use PolyORB.Types;

   package L is new PolyORB.Log.Facility_Log ("polyorb.protocols.giop");
   procedure O (Message : in String; Level : Log_Level := Debug)
     renames L.Output;

   type GIOP_Implem_Desc is record
      Func    : GIOP_Create_Implem_Func;
      Version : GIOP_Version;
   end record;

   GIOP_Implem_List : array (1 .. Max_GIOP_Implem) of GIOP_Implem_Desc;

   Nb_Implem : Natural range  0 .. Max_GIOP_Implem := 0;

   ------------
   -- Create --
   ------------

   procedure Create
     (Proto   : access GIOP_Protocol;
      Session :    out Filter_Access)
   is
      pragma Warnings (Off);
      pragma Unreferenced (Proto);
      pragma Warnings (On);
   begin
      Session := new GIOP_Session;
      pragma Debug (O ("Create GIOP Session"));
      Initialize (GIOP_Session (Session.all));
      Set_Allocation_Class (Session.all, Dynamic);
   end Create;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Conf                  : access GIOP_Conf;
      Version               : in     GIOP_Version;
      Permitted_Sync_Scopes : in     PolyORB.Requests.Flags;
      Locate_Then_Request   : in     Boolean;
      Section               : in     String;
      Prefix                : in     String)
   is
      use PolyORB.Parameters;
      use PolyORB.Utils;

   begin
      pragma Debug (O ("Initialize parameters for GIOP Protocol"));
      pragma Debug (O ("Conf Section : " & Section));
      pragma Debug (O ("Conf Prefix : " & Prefix));

      pragma Debug (O ("Permitted sync scope" & Permitted_Sync_Scopes'Img));
      Conf.Permitted_Sync_Scopes := Permitted_Sync_Scopes;

      Conf.GIOP_Def_Ver.Minor :=
        Types.Octet
        (Get_Conf
         (Section,
          Prefix & ".default_version.minor",
          Integer (Version.Minor)));

      Conf.GIOP_Def_Ver.Major :=
        Types.Octet
        (Get_Conf
         (Section,
          Prefix & ".default_version.major",
          Integer (Version.Major)));

      for J in 1 .. Nb_Implem loop
         if Get_Conf (Section,
                      Prefix
                      & "."
                      & Trimmed_Image
                      (Integer (GIOP_Implem_List (J).Version.Major))
                      & "."
                      & Trimmed_Image
                      (Integer (GIOP_Implem_List (J).Version.Minor))
                      & ".enable", True) then

            pragma Debug (O ("Enable GIOP Version : "
                             & GIOP_Implem_List (J).Version.Major'Img
                             & "."
                             & GIOP_Implem_List (J).Version.Minor'Img));

            Conf.Nb_Implem := Conf.Nb_Implem + 1;

            declare
               Impl : constant GIOP_Implem_Access
                 := GIOP_Implem_List (J).Func.all;
            begin
               Conf.GIOP_Implem_List (Conf.Nb_Implem) := Impl;

               Impl.Version := GIOP_Implem_List (J).Version;

               Impl.Section := To_PolyORB_String (Section);
               Impl.Prefix := To_PolyORB_String (Prefix);

               Initialize_Implem (Impl);

               Impl.Locate_Then_Request :=
                 Get_Conf (Section,
                           Get_Conf_Chain (Impl)
                           & ".locate_then_request",
                           Locate_Then_Request);
            end;
         end if;
      end loop;
   end Initialize;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (S : in out GIOP_Session) is
   begin
      pragma Debug (O ("Initializing GIOP session"));
      S.Buffer_In  := new Buffer_Type;
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize
     (S : in out GIOP_Session) is
   begin
      pragma Debug (O ("Finalizing GIOP session"));

      pragma Assert (Pend_Req_List.Length (S.Pending_Reqs) = 0);
      --  XXX Check the session has no pending requests.
      --  What if there is one ? Should we emit an error message ?

      if S.Buffer_In /= null then
         Release (S.Buffer_In);
      end if;

      if S.Implem /= null then
         Finalize_Session (S.Implem, S'Access);
      end if;

      Protocols.Finalize (Protocols.Session (S));
   end Finalize;

   ----------------------------
   -- Handle_Data_Indication --
   ----------------------------

   procedure Handle_Data_Indication
     (Sess        : access GIOP_Session;
      Data_Amount :        Stream_Element_Count)
   is
      pragma Warnings (Off);
      pragma Unreferenced (Data_Amount);
      pragma Warnings (On);

      Version : GIOP_Version;
   begin
      pragma Debug (O ("Received data in state " & Sess.State'Img));

      pragma Assert (Sess.State /= Not_Initialized);

      case Sess.State is

         when Expect_Header =>

            Unmarshall_Global_GIOP_Header (Sess.Buffer_In, Version);

            if Sess.Implem = null then
               Get_GIOP_Implem (Sess, Version);
            elsif Version /= Sess.Implem.Version then
               raise GIOP_Error;
            end if;

            Unmarshall_GIOP_Header (Sess.Implem, Sess);

            Sess.State := Expect_Body;

            pragma Debug (O ("GIOP Header OK, ask for body, size :"
                             & Sess.Ctx.Message_Size'Img));

            if Sess.Ctx.Message_Size = 0 then
               Process_Message (Sess.Implem, Sess);
            else
               Emit_No_Reply
                 (Port => Lower (Sess),
                  Msg  => GIOP_Data_Expected'
                  (In_Buf => Sess.Buffer_In,
                   Max    => Stream_Element_Count (Sess.Ctx.Message_Size),
                   State  => Sess.State));
            end if;

         when Expect_Body =>
            Process_Message (Sess.Implem, Sess);

         when others =>
            raise GIOP_Error;
      end case;
   end Handle_Data_Indication;

   ---------------------------------
   -- Handle_Unmarshall_Arguments --
   ---------------------------------

   procedure Handle_Unmarshall_Arguments
     (Sess : access GIOP_Session;
      Args : in out Any.NVList.Ref) is
   begin
      pragma Debug (O ("Unmarshalling_Request_Arguments"));
      pragma Assert (Sess.State = Waiting_Unmarshalling);

      Unmarshall_Argument_List
        (Sess.Implem, Sess.Buffer_In, Args,
         PolyORB.Any.ARG_IN, Sess.Implem.Data_Alignment);

      Expect_GIOP_Header (Sess);
   end Handle_Unmarshall_Arguments;

   -------------------------------
   -- Handle_Connect_Indication --
   -------------------------------

   procedure Handle_Connect_Indication
     (Sess : access GIOP_Session) is
   begin
      pragma Debug (O ("Handle_Connect_Indication"));
      pragma Assert (Sess.State = Not_Initialized);

      Sess.Role := Server;
      Expect_GIOP_Header (Sess);
   end Handle_Connect_Indication;

   ---------------------------------
   -- Handle_Connect_Confirmation --
   ---------------------------------

   procedure Handle_Connect_Confirmation
     (Sess : access GIOP_Session) is
   begin
      pragma Debug (O ("Handle_Connect_Confirmation"));
      pragma Assert (Sess.State = Not_Initialized);

      Sess.Role := Client;

      if Sess.Implem = null then
         --  Initialize session with default GIOP version
         Get_GIOP_Implem (Sess, Sess.Conf.GIOP_Def_Ver);
      end if;

      Expect_GIOP_Header (Sess);
   end Handle_Connect_Confirmation;

   -----------------------
   -- Handle_Disconnect --
   -----------------------

   procedure Handle_Disconnect
     (Sess : access GIOP_Session) is
   begin
      pragma Debug (O ("Handle_Disconnect"));

      if Sess.Buffer_In /= null then
         Release (Sess.Buffer_In);
      end if;

      if Sess.Implem /= null then
         Finalize_Session (Sess.Implem, Sess);
         Sess.Implem := null;
      end if;

      Sess.State := Not_Initialized;
   end Handle_Disconnect;

   --------------------
   -- Invoke_Request --
   --------------------

   procedure Invoke_Request
     (Sess : access GIOP_Session;
      R    :        Request_Access;
      Pro  : access Binding_Data.Profile_Type'Class)
   is
      use PolyORB.Binding_Data;
      use Unsigned_Long_Flags;

      New_Pending_Req : Pending_Request_Access;
   begin
      if (Sess.Conf.Permitted_Sync_Scopes and R.Req_Flags) = 0
        or else (Sess.Implem.Permitted_Sync_Scopes and R.Req_Flags) = 0 then
         pragma Debug (O ("Requested sync scope not supported"));
         raise GIOP_Error;
      end if;

      New_Pending_Req := new Pending_Request;
      New_Pending_Req.Req := R;
      New_Pending_Req.Target_Profile := Profile_Access (Pro);

      if Is_Set (Sync_With_Transport, R.Req_Flags) then
         --  XXX avoiding memory leaks with one way calls
         New_Pending_Req.Request_Id := Get_Request_Id (Sess);
         Send_Request (Sess.Implem, Sess, New_Pending_Req);
         Free (New_Pending_Req);
         return;
      end if;

      if Sess.Implem.Locate_Then_Request then
         New_Pending_Req.Locate_Req_Id := Get_Request_Id (Sess);
         Add_Pending_Request (Sess, New_Pending_Req);
         Locate_Object (Sess.Implem, Sess, New_Pending_Req);
      else
         Add_Pending_Request (Sess, New_Pending_Req);
         Send_Request (Sess.Implem, Sess, New_Pending_Req);
      end if;
   end Invoke_Request;

   -------------------
   -- Abort_Request --
   -------------------

   procedure Abort_Request
     (Sess : access GIOP_Session;
      R    :        Requests.Request_Access) is
   begin
      Process_Abort_Request (Sess.Implem, Sess, R);
   end Abort_Request;

   ----------------
   -- Send_Reply --
   ----------------

   procedure Send_Reply
     (Sess : access GIOP_Session;
      R    :        Requests.Request_Access) is
   begin
      Process_Reply (Sess.Implem, Sess, R);
   end Send_Reply;

   ----------------------------
   -- Cancel_Pending_Request --
   ----------------------------

   procedure Cancel_Pending_Request
     (Sess : access GIOP_Session)
   is
      pragma Warnings (Off);
      pragma Unreferenced (Sess);
      pragma Warnings (On);
   begin
      pragma Debug (O ("Cancelling pending request"));
      --  XXX Cancelling pending requests for a session before closing
      --  Not Implemented
      --  This function must stop request which are running
      --  in client AND server mode
      null;
   end Cancel_Pending_Request;

   ------------------
   -- Emit Message --
   ------------------

   procedure Emit_Message
     (Implem : access GIOP_Implem;
      S      : access Session'Class;
      Buffer :        Buffer_Access)
   is
      pragma Warnings (Off);
      pragma Unreferenced (Implem);
      pragma Warnings (On);

      use PolyORB.Filters.Interface;

   begin
      Emit_No_Reply (Lower (S), Data_Out'(Out_Buf => Buffer));
   end Emit_Message;

   -------------------------------------------------------------------------

   --  Local functions

   ------------------------
   -- Expect_GIOP_Header --
   ------------------------

   --  called to wait another GIOP message
   procedure Expect_GIOP_Header
     (Sess : access GIOP_Session) is
   begin

      --  Check if buffer has been totally read

      if Remaining (Sess.Buffer_In) /= 0 then
         pragma Debug (O ("Remaining data in buffer :"
                          & Remaining (Sess.Buffer_In)'Img
                          & " bytes"));
         null;
         --  It is not an error to leave data remaining in Buffer,
         --  e.g. in the case of an (unexpected) unknown user exception.
      end if;

      pragma Debug (O ("Waiting for next message"));

      Buffers.Release_Contents (Sess.Buffer_In.all);
      Sess.State := Expect_Header;
      Emit_No_Reply
        (Port => Lower (Sess),
         Msg  => GIOP_Data_Expected'
         (In_Buf => Sess.Buffer_In,
          Max    => GIOP_Header_Size,
          State  => Sess.State));
   end Expect_GIOP_Header;

   ----------------------------
   -- Unmarshall_GIOP_Header --
   ----------------------------

   procedure Unmarshall_Global_GIOP_Header
     (Buffer  : access Buffer_Type;
      Version :    out GIOP_Version)
   is
      use Octet_Flags;

      Message_Magic : Stream_Element_Array (Magic'Range);
      Flags         : Types.Octet;
   begin
      --  Get Endianness
      --  This code works only if the endianness bit dont move
      --  in different giop version
      Flags := Types.Octet (Peek (Buffer, Flags_Index - 1));
      pragma Debug (O ("Flags : " & Flags'Img));

      if Is_Set (Bit_Little_Endian, Flags) then
         Set_Endianness (Buffer, Little_Endian);
      else
         Set_Endianness (Buffer, Big_Endian);
      end if;

      --  Begining of GIOP message is byte-ordering independent

      --  Magic

      for J in Message_Magic'Range loop
         Message_Magic (J) := Stream_Element
           (Types.Octet'(Unmarshall (Buffer)));
      end loop;

      if Message_Magic /= Magic then
         raise GIOP_Error;
      end if;

      --  Get GIOP Message version
      Version.Major := Unmarshall (Buffer);
      Version.Minor := Unmarshall (Buffer);

      pragma Debug (O ("Received GIOP message, version:"
                       & Version.Major'Img
                       & "."
                       & Version.Minor'Img));
   end Unmarshall_Global_GIOP_Header;

   ---------------------------------
   -- Marshall_Global_GIOP_Header --
   ---------------------------------

   procedure Marshall_Global_GIOP_Header
     (Sess   : access GIOP_Session;
      Buffer : access PolyORB.Buffers.Buffer_Type)
   is
   begin
      --  Magic

      for J in Magic'Range loop
         Marshall (Buffer, Types.Octet (Magic (J)));
      end loop;

      --  Version

      Marshall (Buffer, Sess.Implem.Version.Major);
      Marshall (Buffer, Sess.Implem.Version.Minor);

      --  Implem-specific data

      Marshall_GIOP_Header (Sess.Implem, Sess, Buffer);

   end Marshall_Global_GIOP_Header;

   -----------------------------------
   -- Marshall_Service_Context_List --
   -----------------------------------

   procedure Marshall_Service_Context_List
     (Buffer : access Buffers.Buffer_Type) is
   begin
      Marshall (Buffer, Types.Unsigned_Long (0));
   end Marshall_Service_Context_List;

   -------------------------------------
   -- Unmarshall_Service_Context_List --
   -------------------------------------

   procedure Unmarshall_Service_Context_List
     (Buffer : access Buffers.Buffer_Type)
   is
      Length : constant PolyORB.Types.Unsigned_Long := Unmarshall (Buffer);

   begin
      pragma Debug (O ("Unmarshall_Service_Context_List: enter, length ="
                       & PolyORB.Types.Unsigned_Long'Image (Length)));

      for J in 1 .. Length loop
         declare
            Context_Id   : constant Types.Unsigned_Long := Unmarshall (Buffer);
            Context_Data : constant Encapsulation := Unmarshall (Buffer);
            pragma Warnings (Off);
            pragma Unreferenced (Context_Id, Context_Data);
            pragma Warnings (On);
         begin
            null;
         end;
      end loop;

      pragma Debug (O ("Unmarshall_Service_Context_List: leave"));
   end Unmarshall_Service_Context_List;

   ------------------------------
   -- Unmarshall_Argument_List --
   ------------------------------

   procedure Unmarshall_Argument_List
     (Implem              : access GIOP_Implem;
      Buffer              :        Buffer_Access;
      Args                : in out Any.NVList.Ref;
      Direction           :        Any.Flags;
      First_Arg_Alignment :        Opaque.Alignment_Type)
   is
      pragma Warnings (Off);
      pragma Unreferenced (Implem);
      pragma Warnings (On);

      use PolyORB.Any;
      use PolyORB.Any.NVList.Internals;
      use PolyORB.Any.NVList.Internals.NV_Lists;

      It  : Iterator := First (List_Of (Args).all);
      Arg : Element_Access;
   begin
      pragma Assert (Direction = ARG_IN or else Direction = ARG_OUT);

      if not Last (It) then
         Align_Position (Buffer, First_Arg_Alignment);
      end if;

      while not Last (It) loop
         Arg := Value (It);
         if False
           or else Arg.Arg_Modes = Direction
           or else Arg.Arg_Modes = ARG_INOUT
         then
            Unmarshall_To_Any (Buffer, Arg.Argument);
         end if;
         Next (It);
      end loop;
   end Unmarshall_Argument_List;

   ----------------------------
   -- Marshall_Argument_List --
   ----------------------------

   procedure Marshall_Argument_List
     (Implem              : access GIOP_Implem;
      Buffer              :        Buffer_Access;
      Args                : in out Any.NVList.Ref;
      Direction           :        Any.Flags;
      First_Arg_Alignment :        Opaque.Alignment_Type)
   is
      pragma Warnings (Off);
      pragma Unreferenced (Implem);
      pragma Warnings (On);

      use PolyORB.Any;
      use PolyORB.Any.NVList.Internals;
      use PolyORB.Any.NVList.Internals.NV_Lists;

      It  : Iterator := First (List_Of (Args).all);
      Arg : Element_Access;
   begin
      pragma Assert (Direction = ARG_IN or Direction = ARG_OUT);

      if not Last (It) then
         Pad_Align (Buffer, First_Arg_Alignment);
      end if;

      while not Last (It) loop
         Arg := Value (It);

         if False
           or else Arg.Arg_Modes = Direction
           or else Arg.Arg_Modes = ARG_INOUT
         then
            pragma Debug (O ("Marshalling argument "
                             & Types.To_Standard_String (Arg.Name)
                             & " = " & Image (Arg.Argument)));

            Marshall (Buffer, Arg.all);
         end if;

         Next (It);
      end loop;
   end Marshall_Argument_List;

   ----------------------------------------
   -- Unmarshall_System_Exception_To_Any --
   ----------------------------------------

   procedure Unmarshall_System_Exception_To_Any
     (Buffer :     Buffer_Access;
      Info   : out Any.Any)
   is
      use PolyORB.GIOP_P.Exceptions;

      Exception_Name : constant String
        := Extract_System_Exception_Name (Unmarshall (Buffer));

   begin
      Info := Any.Get_Empty_Any (System_Exception_TypeCode (Exception_Name));
      Unmarshall_To_Any (Buffer, Info);
   end Unmarshall_System_Exception_To_Any;

   --------------------
   -- Select_Profile --
   --------------------

   function Select_Profile
     (Buffer  : access Buffer_Type)
     return PolyORB.Binding_Data.Profile_Access
   is
      use PolyORB.Binding_Data;
      use PolyORB.References;

      New_Ref    : constant PolyORB.References.Ref
        := Representations.CDR.Unmarshall (Buffer);
      Prof_Array : constant PolyORB.References.Profile_Array
        := Profiles_Of (New_Ref);

   begin
      for J in Prof_Array'Range loop
         if Get_Profile_Tag (Prof_Array (J).all) = Tag_Internet_IOP then
            return Prof_Array (J);
         end if;
      end loop;

      return null;
   end Select_Profile;

   --  Version management

   ----------------------------------
   -- Global_Register_GIOP_Version --
   ----------------------------------

   procedure Global_Register_GIOP_Version
     (Version : GIOP_Version;
      Implem  : GIOP_Create_Implem_Func) is
   begin
      if Implem /= null then
         Nb_Implem := Nb_Implem + 1;
         GIOP_Implem_List (Nb_Implem)
           := GIOP_Implem_Desc'(Version => Version, Func => Implem);
      end if;
   end Global_Register_GIOP_Version;

   ---------------------
   -- Get_GIOP_Implem --
   ---------------------

   procedure Get_GIOP_Implem
     (Sess    : access GIOP_Session;
      Version :        GIOP_Version)
   is
      use PolyORB.Utils;

   begin
      pragma Debug (O ("Looking up implementation for version "
                       & Trimmed_Image (Integer (Version.Major))
                       & "."
                       & Trimmed_Image (Integer (Version.Minor))));

      for J in 1 .. Sess.Conf.Nb_Implem loop
         if Sess.Conf.GIOP_Implem_List (J).Version = Version then

            Sess.Implem := Sess.Conf.GIOP_Implem_List (J);
            Initialize_Session (Sess.Implem, Sess);
            return;
         end if;
      end loop;

      raise GIOP_Unknown_Version;
   end Get_GIOP_Implem;

   -------------------------
   -- Get_Pending_Request --
   -------------------------

   procedure Get_Pending_Request
     (Sess    : access GIOP_Session;
      Id      :        Types.Unsigned_Long;
      Req     :    out Pending_Request_Access;
      Success :    out Boolean)
   is
      use Pend_Req_List;

      It : Iterator := First (Sess.Pending_Reqs);

   begin
      pragma Debug (O ("Retrieving pending request with id"
                       & Types.Unsigned_Long'Image (Id)));

      while not Last (It) loop
         if Pending_Request_Access (Value (It).all).Request_Id = Id then
            Req := Pending_Request_Access (Value (It).all);
            Remove (Sess.Pending_Reqs, It);
            Success := True;
            return;
         end if;
         Next (It);
      end loop;

      Success := False;
   end Get_Pending_Request;

   -----------------------------------
   -- Get_Pending_Request_By_Locate --
   -----------------------------------

   procedure Get_Pending_Request_By_Locate
     (Sess    : access GIOP_Session;
      Id      :        Types.Unsigned_Long;
      Req     :    out Pending_Request_Access;
      Success :    out Boolean)
   is
      use Pend_Req_List;

      It : Iterator := First (Sess.Pending_Reqs);

   begin
      pragma Debug (O ("Retrieving pending request with locate id"
                       & Types.Unsigned_Long'Image (Id)));

      while not Last (It) loop
         if Pending_Request_Access (Value (It).all).Locate_Req_Id = Id then
            Req := Pending_Request_Access (Value (It).all);
            Success := True;
            return;
         end if;
         Next (It);
      end loop;

      Success := False;
   end Get_Pending_Request_By_Locate;

   -------------------------
   -- Add_Pending_Request --
   -------------------------

   procedure Add_Pending_Request
     (Sess     : access GIOP_Session;
      Pend_Req : in     Pending_Request_Access)
   is
      use Pend_Req_List;

      Request_Id : constant Types.Unsigned_Long := Get_Request_Id (Sess);
   begin
      pragma Debug (O ("Adding pending request with id"
                       & Request_Id'Img));
      Set_Note
        (Pend_Req.Req.Notepad,
         Request_Note'(Annotations.Note with Id => Request_Id));
      Pend_Req.Request_Id := Request_Id;
      Append (Sess.Pending_Reqs, Pend_Req);
   end Add_Pending_Request;

   --------------------
   -- Get_Request_Id --
   --------------------

   function Get_Request_Id
     (Sess : access GIOP_Session)
     return Types.Unsigned_Long
   is
      R : Types.Unsigned_Long;
   begin

      --  XXX should we protect Sess.Req_Index against concurrent accesses ?

      R := Sess.Req_Index;
      Sess.Req_Index := Sess.Req_Index + 1;
      return R;
   end Get_Request_Id;

   --------------------
   -- Get_Conf_Chain --
   --------------------

   function Get_Conf_Chain
     (Implem : access GIOP_Implem'Class)
     return String
   is
      use PolyORB.Utils;

   begin
      return To_Standard_String (Implem.Prefix)
        & "."
        & Trimmed_Image (Integer (Implem.Version.Major))
        & "."
        & Trimmed_Image (Integer (Implem.Version.Minor));
   end Get_Conf_Chain;

end PolyORB.Protocols.GIOP;
