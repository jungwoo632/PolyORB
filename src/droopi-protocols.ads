--  Support for object method invocation protocols.

--  $Id$

with Ada.Streams;

with Droopi.Buffers;
with Droopi.Components;
with Droopi.Filters; use Droopi.Filters;
with Droopi.Requests; use Droopi.Requests;
with Droopi.Soft_Links; use Droopi.Soft_Links;
with Droopi.ORB.Interface;

package Droopi.Protocols is

   pragma Elaborate_Body;

   --  A protocol is a factory of sessions. Each session corresponds
   --  to a connection to a remote protocol entity.

   --  This package needs some comments and in particular the callback
   --  and the demux stuff.

   type Protocol is abstract new Filters.Factory with private;
   type Protocol_Access is access all Protocol'Class;

   type Session is abstract new Filters.Filter with private;
   type Session_Access is access all Session'Class;

   procedure Create
     (Proto   : access Protocol;
      Session : out Filter_Access)
      is abstract;
   --  Create a Session for protocol Proto using filter Lower.

   --  XXXXX: does not create request_watcher !

   --  XXXXX: Filter_Access should be Filter_Access

   procedure Destroy_Session (S : in out Session_Access);
   --  Destroy the session associated with S, return any associated
   --  resources to the system, and assign null to S.

   procedure Set_Request_Watcher
     (S : in Session_Access;
      W : Droopi.Soft_Links.Watcher_Access);
   --

   function Get_Request_Watcher
     (S : in Session_Access)
     return Droopi.Soft_Links.Watcher_Access;
   --  Return the request watcher associated with session.

   function Get_Pending_Request
     (S : in Session_Access)
     return ORB.Interface.Queue_Request;
   --  Return the request watcher associated with session.
   --  XXX The comment above is wrong, please update it.
   --  XXX The use of the term 'Pending_Request' is inappropriate
   --      in this context. A pending request is a request object
   --      on the client side of a connection which has been
   --      sent to the target object and for which a response
   --      is expected. Please find another, more explicit term.

   -----------------------------------------------------
   -- Protocol primitives (interface to upper layers) --
   -----------------------------------------------------

   procedure Invoke_Request (S : access Session; R : Request)
      is abstract;
   --  Send a method invocation message for request R on session S.

   procedure Abort_Request (S : access Session; R : Request)
      is abstract;
   --  Abort pending invocation of R.

   procedure Send_Reply (S : access Session; R : Request)
      is abstract;
   --  Send back a reply on S notifying caller of the result
   --  of executing R.

   --  XXX
   --  Primitives of Session might be derived from the primitives
   --  of AdaBroker type Broca.IOP.Connection_Type.

--     -----------------------------------
--     -- Abstract GIOP connection type --
--     -----------------------------------
--
--     type Connection_Type is abstract tagged private;
--     type Connection_Ptr is access all Connection_Type'Class;
--
--     function Get_Request
--       (Connection : access Connection_Type)
--       return CORBA.Unsigned_Long;
--     --  Get a new request id for this connection.
--
--     procedure Release
--       (Connection : access Connection_Type) is abstract;
--     --  Release a previously suspended connection.
--
--     procedure Send
--       (Connection : access Connection_Type;
--        Buffer     : access Buffers.Buffer_Type) is abstract;
--     --  Send a buffer to a connection. Raise Comm_Failure on error.
--
--     function Receive
--       (Connection : access Connection_Type;
--        Length     : Opaque.Index_Type)
--       return Opaque.Octet_Array_Ptr is abstract;
--     --  Receive data from a connection. Raise Comm_Failure on error.

   ------------------------------------------------
   -- Callback point (interface to lower layers) --
   ------------------------------------------------

   procedure Handle_Connect_Indication (S : access Session)
      is abstract;
   --  A new server connection has been accepted as session S.

   procedure Handle_Connect_Confirmation (S : access Session)
      is abstract;
   --  A new client connection has been established as session S.

   procedure Handle_Data_Indication (S : access Session) is abstract;
   --  Invoked when some data arrives for session S.

   procedure Handle_Disconnect (S : access Session) is abstract;
   --  Invoked when the underlying connection is closed.

   ---------------------
   -- Message demuxer --
   ---------------------

   function Handle_Message
     (Sess : access Session;
      S : Components.Message'Class)
     return Components.Message'Class;
   --  Demultiplex Messages to the above specialized operations.

private

   type Protocol is abstract new Filters.Factory with null record;

   type Session is abstract new Filters.Filter with record
      Server          : Components.Component_Access;
      Request_Watcher : Droopi.Soft_Links.Watcher_Access := null;
      Pending_Request : ORB.Interface.Queue_Request;
      --  XXX Change 'Pending' to something else (see above).
      --  XXX Storage of a Message'Class is questionable (Messages
      --    are supposed to be synchronously delivered, as per the
      --    documentation in the spec of Droopi.Components.
      --    Store-and-forward behaviour is not expected.)
   end record;

   procedure Expect_Data
     (S      : access Session;
      In_Buf : Buffers.Buffer_Access;
      Max    : Ada.Streams.Stream_Element_Count);

end Droopi.Protocols;
