------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                           A W S . S T A T U S                            --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2000-2012, Free Software Foundation, Inc.          --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.                                               --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
--                  PolyORB is maintained by AdaCore                        --
--                     (email: sales@adacore.com)                           --
--                                                                          --
------------------------------------------------------------------------------

--  This package is used to keep the HTTP protocol status. Client can then
--  request the status for various values like the requested URI, the
--  Content_Length and the Session ID for example.

--  to be changed, as we use aws.net

with Ada.Streams;
with Ada.Strings.Unbounded;

with AWS.Headers;
--  with AWS.Net
with AWS.Parameters;
with AWS.Session;
with AWS.URL;
with AWS.Utils;

with SOAP.Message.Payload;

package AWS.Status is

   type Data is private;

   type Data_Access is access all Data;

   type Request_Method is (GET, HEAD, POST, PUT);

   type Authorization_Type is (None, Basic, Digest);

   function Check_Digest (D : Data; Password : String) return Boolean;
   --  This function is used by the digest authentication to check if the
   --  client password is correct.
   --  The password is not transferred between the client and the server,
   --  the server check that the client knows the right password using the
   --  MD5 checksum.

   function Authorization_Mode     (D : Data) return Authorization_Type;
   pragma Inline (Authorization_Mode);
   --  Get the type of the "Authorization:" parameter

   function Authorization_Name     (D : Data) return String;
   pragma Inline (Authorization_Name);
   --  Get the value for the name in the "Authorization:" parameter

   function Authorization_Password (D : Data) return String;
   pragma Inline (Authorization_Password);
   --  Get the value for the password in the "Authorization:" parameter

   function Authorization_Realm    (D : Data) return String;
   pragma Inline (Authorization_Realm);
   --  Get the value for the "realm" in the "Authorization:" parameter

   function Authorization_Nonce    (D : Data) return String;
   pragma Inline (Authorization_Nonce);
   --  Get the value for the "nonce" in the "Authorization:" parameter

   function Authorization_NC       (D : Data) return String;
   pragma Inline (Authorization_NC);
   --  Get the value for the "nc" in the "Authorization:" parameter

   function Authorization_CNonce   (D : Data) return String;
   pragma Inline (Authorization_CNonce);
   --  Get the value for the "cnonce" in the "Authorization:" parameter

   function Authorization_QOP      (D : Data) return String;
   pragma Inline (Authorization_QOP);
   --  Get the value for the "qop" in the "Authorization:" parameter

   function Authorization_Response (D : Data) return String;
   pragma Inline (Authorization_Response);
   --  Get the value for the "response" in the "Authorization:" parameter

   function Connection             (D : Data) return String;
   pragma Inline (Connection);
   --  Get the value for "Connection:" parameter

   function Content_Length         (D : Data) return Natural;
   pragma Inline (Content_Length);
   --  Get the value for "Content-Length:" parameter, this is the number of
   --  bytes in the message body.

   function Content_Type           (D : Data) return String;
   pragma Inline (Content_Type);
   --  Get value for "Content-Type:" parameter

   function Has_Session            (D : Data) return Boolean;
   pragma Inline (Has_Session);
   --  Returns true if a session ID has been received.

   function Host                   (D : Data) return String;
   pragma Inline (Host);
   --  Get value for "Host:" parameter

   function HTTP_Version           (D : Data) return String;
   pragma Inline (HTTP_Version);
   --  Returns the HTTP version used by the client.

   function If_Modified_Since      (D : Data) return String;
   pragma Inline (If_Modified_Since);
   --  Get value for "If-Modified-Since:" parameter

   function Keep_Alive             (D : Data) return Boolean;
   pragma Inline (Keep_Alive);
   --  Returns the flag if the current HTTP connection is keep-alive.

   function Method                 (D : Data) return Request_Method;
   pragma Inline (Method);
   --  Returns the request method.

   function Multipart_Boundary     (D : Data) return String;
   pragma Inline (Multipart_Boundary);
   --  Get value for the boundary part in "Content-Type: ...; boundary=..."
   --  parameter. This is a string that will be used to separate each chunk of
   --  data in a multipart message.

   function Parameters             (D : Data) return Parameters.List;
   pragma Inline (Parameters);
   --  Returns the list of parameters for the request. This list can be empty
   --  if there was no form or URL parameters.

   function Peername               (D : Data) return String;
   pragma Inline (Peername);
   --  Returns the name of the peer (the name of the client computer)

   function Session                (D : Data) return Session.ID;
   pragma Inline (Session);
   --  Returns the Session ID for the request.

   function Session_Created        (D : Data) return Boolean;
   --  Returns True if session was just created and is going to be sent to
   --  client.

--     function Socket            (D : Data) return Net.Socket_Type'Class;
--     pragma Inline (Socket);
   --  Returns the socket used to transfert data between the client and
   --  server.

   function URI                    (D : Data) return String;
   pragma Inline (URI);
   --  Returns the requested resource.

   function URI                    (D : Data) return URL.Object;
   pragma Inline (URI);
   --  As above but return an URL object.

   function User_Agent             (D : Data) return String;
   pragma Inline (User_Agent);
   --  Get value for "User-Agent:" parameter

   function Referer                (D : Data) return String;
   pragma Inline (Referer);
   --  Get value for "Referer:" parameter

   function Is_SOAP                (D : Data) return Boolean;
   pragma Inline (Is_SOAP);
   --  Returns True if it is a SOAP request. In this case SOAPAction return
   --  the SOAPAction header and Payload returns the XML SOAP Payload message.

   function SOAPAction             (D : Data) return String;
   pragma Inline (SOAPAction);
   --  Get value for "SOAPAction:" parameter. This is a standard header to
   --  support SOAP over HTTP protocol.

   function Payload                (D : Data) return String;
   pragma Inline (Payload);
   --  Returns the XML Payload message. XML payload is the actual SOAP request

   function Payload (D : Data) return SOAP.Message.Payload.Object;
   --  Returns the AWS_SOAP structure of the payload. This is meant for
   --  PolyORB/AWS, as we have to decode the payload before creating the
   --  status, while original AWS does it afterwards.

   subtype Stream_Element_Array is Ada.Streams.Stream_Element_Array;

   function Binary_Data (D : Data) return Stream_Element_Array;
   pragma Inline (Binary_Data);
   --  Returns the binary data message content.

   function Header (D : Data) return Headers.List;
   pragma Inline (Header);
   --  Returns the list of header lines for the request.

private

   use Ada.Strings.Unbounded;

   type Data is record
      Peername          : Unbounded_String;
      Method            : Request_Method     := GET;
      URI               : URL.Object;
      Parameters        : AWS.Parameters.List;
      Header            : Headers.List;
      Binary_Data       : Utils.Stream_Element_Array_Access := null;
      HTTP_Version      : Unbounded_String;
      Content_Length    : Natural            := 0;
      Keep_Alive        : Boolean;
      File_Up_To_Date   : Boolean            := False;
      SOAP_Action       : Boolean            := False;
--      Socket            : Net.Socket_Access;
      Auth_Mode         : Authorization_Type := None;
      Auth_Name         : Unbounded_String; -- for Basic and Digest
      Auth_Password     : Unbounded_String; -- for Basic
      Auth_Realm        : Unbounded_String; -- for Digest
      Auth_Nonce        : Unbounded_String; -- for Digest
      Auth_NC           : Unbounded_String; -- for Digest
      Auth_CNonce       : Unbounded_String; -- for Digest
      Auth_QOP          : Unbounded_String; -- for Digest
      Auth_Response     : Unbounded_String; -- for Digest
      Session_ID        : AWS.Session.ID     := AWS.Session.No_Session;
      Session_Created   : Boolean            := False;
--      Payload           : Unbounded_String;
      SOAP_Payload      : SOAP.Message.Payload.Object;
   end record;

end AWS.Status;
