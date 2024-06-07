// This file defines test cases that test HTTP payload bindings.
// See: https://smithy.io/2.0/spec/http-bindings.html#httppayload-trait

$version: "2.0"

namespace aws.protocoltests.restjson

use aws.protocols#restJson1
use smithy.test#httpMalformedRequestTests
use aws.protocoltests.shared#TextPlainBlob
use smithy.test#httpRequestTests
use smithy.test#httpResponseTests

/// This example serializes a blob shape in the payload.
///
/// In this example, no JSON document is synthesized because the payload is
/// not a structure or a union type.
@http(uri: "/HttpPayloadTraits", method: "POST")
operation HttpPayloadTraits {
    input: HttpPayloadTraitsInputOutput,
    output: HttpPayloadTraitsInputOutput
}

apply HttpPayloadTraits @httpRequestTests([
    {
        id: "RestJsonHttpPayloadTraitsWithBlob",
        documentation: "Serializes a blob in the HTTP payload",
        protocol: restJson1,
        method: "POST",
        uri: "/HttpPayloadTraits",
        body: "blobby blob blob",
        bodyMediaType: "application/octet-stream",
        headers: {
            "Content-Type": "application/octet-stream",
            "X-Foo": "Foo"
        },
        requireHeaders: [
            "Content-Length"
        ],
        params: {
            foo: "Foo",
            blob: "blobby blob blob"
        }
    },
    {
        id: "RestJsonHttpPayloadTraitsWithNoBlobBody",
        documentation: "Serializes an empty blob in the HTTP payload",
        protocol: restJson1,
        method: "POST",
        uri: "/HttpPayloadTraits",
        body: "",
        bodyMediaType: "application/octet-stream",
        headers: {
            "X-Foo": "Foo"
        },
        params: {
            foo: "Foo"
        }
    },
    {
        id: "RestJsonHttpPayloadTraitsWithBlobAcceptsAllContentTypes",
        documentation: """
            Servers must accept any content type for blob inputs
            without the media type trait.""",
        protocol: restJson1,
        method: "POST",
        uri: "/HttpPayloadTraits",
        body: "This is definitely a jpeg",
        bodyMediaType: "application/octet-stream",
        headers: {
            "X-Foo": "Foo",
            "Content-Type": "image/jpeg"
        },
        params: {
            foo: "Foo",
            blob: "This is definitely a jpeg"
        },
        appliesTo: "server",
    },
    {
        id: "RestJsonHttpPayloadTraitsWithBlobAcceptsNoContentType",
        documentation: """
            Servers must accept no content type for blob inputs
            without the media type trait.""",
        protocol: restJson1,
        method: "POST",
        uri: "/HttpPayloadTraits",
        body: "This is definitely a jpeg",
        bodyMediaType: "application/octet-stream",
        headers: {
            "X-Foo": "Foo",
        },
        params: {
            foo: "Foo",
            blob: "This is definitely a jpeg"
        },
        appliesTo: "server",
        tags: [ "content-type" ]
    },
    {
        id: "RestJsonHttpPayloadTraitsWithBlobAcceptsAllAccepts",
        documentation: """
            Servers must accept any accept header for blob inputs
            without the media type trait.""",
        protocol: restJson1,
        method: "POST",
        uri: "/HttpPayloadTraits",
        body: "This is definitely a jpeg",
        bodyMediaType: "application/octet-stream",
        headers: {
            "X-Foo": "Foo",
            "Accept": "image/jpeg"
        },
        params: {
            foo: "Foo",
            blob: "This is definitely a jpeg"
        },
        appliesTo: "server",
    },
])

apply HttpPayloadTraits @httpResponseTests([
    {
        id: "RestJsonHttpPayloadTraitsWithBlob",
        documentation: "Serializes a blob in the HTTP payload",
        protocol: restJson1,
        code: 200,
        body: "blobby blob blob",
        bodyMediaType: "application/octet-stream",
        headers: {
            "X-Foo": "Foo"
        },
        params: {
            foo: "Foo",
            blob: "blobby blob blob"
        }
    },
    {
        id: "RestJsonHttpPayloadTraitsWithNoBlobBody",
        documentation: "Serializes an empty blob in the HTTP payload",
        protocol: restJson1,
        code: 200,
        body: "",
        bodyMediaType: "application/octet-stream",
        headers: {
            "X-Foo": "Foo"
        },
        params: {
            foo: "Foo"
        }
    },
])

structure HttpPayloadTraitsInputOutput {
    @httpHeader("X-Foo")
    foo: String,

    @httpPayload
    blob: Blob,
}

/// This example uses a `@mediaType` trait on the payload to force a custom
/// content-type to be serialized.
@http(uri: "/HttpPayloadTraitsWithMediaType", method: "POST")
operation HttpPayloadTraitsWithMediaType {
    input: HttpPayloadTraitsWithMediaTypeInputOutput,
    output: HttpPayloadTraitsWithMediaTypeInputOutput
}

apply HttpPayloadTraitsWithMediaType @httpRequestTests([
    {
        id: "RestJsonHttpPayloadTraitsWithMediaTypeWithBlob",
        documentation: "Serializes a blob in the HTTP payload with a content-type",
        protocol: restJson1,
        method: "POST",
        uri: "/HttpPayloadTraitsWithMediaType",
        body: "blobby blob blob",
        bodyMediaType: "application/octet-stream",
        headers: {
            "X-Foo": "Foo",
            "Content-Type": "text/plain"
        },
        requireHeaders: [
            "Content-Length"
        ],
        params: {
            foo: "Foo",
            blob: "blobby blob blob"
        }
    }
])

apply HttpPayloadTraitsWithMediaType @httpResponseTests([
    {
        id: "RestJsonHttpPayloadTraitsWithMediaTypeWithBlob",
        documentation: "Serializes a blob in the HTTP payload with a content-type",
        protocol: restJson1,
        code: 200,
        body: "blobby blob blob",
        bodyMediaType: "application/octet-stream",
        headers: {
            "X-Foo": "Foo",
            "Content-Type": "text/plain"
        },
        params: {
            foo: "Foo",
            blob: "blobby blob blob"
        }
    }
])

structure HttpPayloadTraitsWithMediaTypeInputOutput {
    @httpHeader("X-Foo")
    foo: String,

    @httpPayload
    blob: TextPlainBlob,
}

/// This example serializes a structure in the payload.
///
/// Note that serializing a structure changes the wrapper element name
/// to match the targeted structure.
@idempotent
@http(uri: "/HttpPayloadWithStructure", method: "PUT")
operation HttpPayloadWithStructure {
    input: HttpPayloadWithStructureInputOutput,
    output: HttpPayloadWithStructureInputOutput
}

apply HttpPayloadWithStructure @httpRequestTests([
    {
        id: "RestJsonHttpPayloadWithStructure",
        documentation: "Serializes a structure in the payload",
        protocol: restJson1,
        method: "PUT",
        uri: "/HttpPayloadWithStructure",
        body: """
              {
                  "greeting": "hello",
                  "name": "Phreddy"
              }""",
        bodyMediaType: "application/json",
        headers: {
            "Content-Type": "application/json"
        },
        requireHeaders: [
            "Content-Length"
        ],
        params: {
            nested: {
                greeting: "hello",
                name: "Phreddy"
            }
        }
    }
])

apply HttpPayloadWithStructure @httpResponseTests([
    {
        id: "RestJsonHttpPayloadWithStructure",
        documentation: "Serializes a structure in the payload",
        protocol: restJson1,
        code: 200,
        body: """
              {
                  "greeting": "hello",
                  "name": "Phreddy"
              }""",
        bodyMediaType: "application/json",
        headers: {
            "Content-Type": "application/json"
        },
        params: {
            nested: {
                greeting: "hello",
                name: "Phreddy"
            }
        }
    }
])

structure HttpPayloadWithStructureInputOutput {
    @httpPayload
    nested: NestedPayload,
}

structure NestedPayload {
    greeting: String,
    name: String,
}

/// This example serializes a union in the payload.
@idempotent
@http(uri: "/HttpPayloadWithUnion", method: "PUT")
operation HttpPayloadWithUnion {
    input: HttpPayloadWithUnionInputOutput,
    output: HttpPayloadWithUnionInputOutput
}

apply HttpPayloadWithUnion @httpRequestTests([
    {
        id: "RestJsonHttpPayloadWithUnion",
        documentation: "Serializes a union in the payload.",
        protocol: restJson1,
        method: "PUT",
        uri: "/HttpPayloadWithUnion",
        body: """
              {
                  "greeting": "hello"
              }""",
        bodyMediaType: "application/json",
        headers: {
            "Content-Type": "application/json"
        },
        requireHeaders: [
            "Content-Length"
        ],
        params: {
            nested: {
                greeting: "hello"
            }
        }
    },
    {
        id: "RestJsonHttpPayloadWithUnsetUnion",
        documentation: "No payload is sent if the union has no value.",
        protocol: restJson1,
        method: "PUT",
        uri: "/HttpPayloadWithUnion",
        body: "",
        params: {}
    }
])

apply HttpPayloadWithUnion @httpResponseTests([
    {
        id: "RestJsonHttpPayloadWithUnion",
        documentation: "Serializes a union in the payload.",
        protocol: restJson1,
        code: 200,
        body: """
              {
                  "greeting": "hello"
              }""",
        bodyMediaType: "application/json",
        headers: {
            "Content-Type": "application/json"
        },
        params: {
            nested: {
                greeting: "hello"
            }
        }
    },
    {
        id: "RestJsonHttpPayloadWithUnsetUnion",
        documentation: "No payload is sent if the union has no value.",
        protocol: restJson1,
        code: 200,
        body: "",
        headers: {
            "Content-Length": "0"
        },
        params: {}
    }
])

structure HttpPayloadWithUnionInputOutput {
    @httpPayload
    nested: UnionPayload,
}

union UnionPayload {
    greeting: String
}

/// This example serializes a string shape in the payload.
///
/// In this example, no JSON document is synthesized because the payload is
/// not a structure or a union type.
@http(uri: "/HttpPayloadTraitOnString", method: "POST")
operation HttpPayloadTraitOnString {
    input: HttpPayloadTraitOnStringInputOutput,
    output: HttpPayloadTraitOnStringInputOutput
}

structure HttpPayloadTraitOnStringInputOutput {
    @httpPayload
    foo: String,
}

apply HttpPayloadTraitOnString @httpRequestTests([
    {
        id: "RestJsonHttpPayloadTraitOnString",
        documentation: "Serializes a string in the HTTP payload",
        protocol: restJson1,
        method: "POST",
        uri: "/HttpPayloadTraitOnString",
        body: "Foo",
        bodyMediaType: "text/plain",
        headers: {
            "Content-Type": "text/plain",
        },
        requireHeaders: [
            "Content-Length"
        ],
        params: {
            foo: "Foo",
        }
    },
])

apply HttpPayloadTraitOnString @httpResponseTests([
    {
        id: "RestJsonHttpPayloadTraitOnString",
        documentation: "Serializes a string in the HTTP payload",
        protocol: restJson1,
        code: 200,
        body: "Foo",
        bodyMediaType: "text/plain",
        headers: {
            "Content-Type": "text/plain",
        },
        params: {
            foo: "Foo",
        }
    },
])

apply HttpPayloadTraitOnString @httpMalformedRequestTests([
    {
        id: "RestJsonHttpPayloadTraitOnStringNoContentType",
        documentation: "Serializes a string in the HTTP payload without a content-type header",
        protocol: restJson1,
        request: {
            method: "POST",
            uri: "/HttpPayloadTraitOnString",
            body: "Foo",
            // We expect a `Content-Type` header but none was provided.
        },
        response: {
            code: 415,
            headers: {
                "x-amzn-errortype": "UnsupportedMediaTypeException"
            }
        },
        tags: [ "content-type" ]
    },
    {
        id: "RestJsonHttpPayloadTraitOnStringWrongContentType",
        documentation: "Serializes a string in the HTTP payload without the expected content-type header",
        protocol: restJson1,
        request: {
            method: "POST",
            uri: "/HttpPayloadTraitOnString",
            body: "Foo",
            headers: {
                // We expect `text/plain`.
                "Content-Type": "application/json",
            },
        },
        response: {
            code: 415,
            headers: {
                "x-amzn-errortype": "UnsupportedMediaTypeException"
            }
        },
        tags: [ "content-type" ]
    },
    {
        id: "RestJsonHttpPayloadTraitOnStringUnsatisfiableAccept",
        documentation: "Serializes a string in the HTTP payload with an unstatisfiable accept header",
        protocol: restJson1,
        request: {
            method: "POST",
            uri: "/HttpPayloadTraitOnString",
            body: "Foo",
            headers: {
                "Content-Type": "text/plain",
                // We can't satisfy this requirement; the server will return `text/plain`.
                "Accept": "application/json",
            },
        },
        response: {
            code: 406,
            headers: {
                "x-amzn-errortype": "NotAcceptableException"
            }
        },
        tags: [ "accept" ]
    },
])
