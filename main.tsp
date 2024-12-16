import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";
import "@typespec/versioning";

using TypeSpec.Versioning;
using TypeSpec.Rest;
using TypeSpec.Http;

@service({
  title: "Smart Task",
})
@server("http://localhost", "Single server endpoint")
@versioned(SmartTask.Versions)
namespace SmartTask;

enum Versions {
  v1: "1.0",
}

@route("/tags")
namespace Tags {
  @get
  op listTags(): {
    @statusCode statusCode: 200;
    @body tags: Models.Tag[];
  };

  @get
  op getTag(@path id: string): {
    @statusCode statusCode: 200;
    @body tag: Models.Tag;
  };

  @post
  op createTag(@path id: string, @body tag: Models.Tag): {
    @statusCode statusCode: 201;
    @body tag: Models.Tag;
  } | {
    @statusCode statusCode: 202;
    @body tag: Models.Tag;
  };

  @put
  op updateTag(@path id: string, @body tag: Models.Tag): {
    @statusCode statusCode: 200;
    @body tag: Models.Tag;
  };

  @delete
  op deleteTag(@path id: string): {
    @statusCode statusCode: 204;
  };
}

namespace Models {
  model Tag {
    @visibility(Lifecycle.Read, Lifecycle.Update)
    id: string;

    name: string;
    color: int32;
    createdAt: utcDateTime;
    updatedAt: utcDateTime;
  }

  enum Status {
    inbox: "inbox",
    nextAction: "nextAction",
    waiting: "waiting",
    done: "done",
  }

  enum Priority {
    low: "low",
    medium: "medium",
    high: "high",
  }

  model Task {
    @visibility(Lifecycle.Read, Lifecycle.Update)
    id: string;

    projectId?: string;
    title: string;
    description: string;
    status: Status;
    priority: Priority;
    tags: Tag[];
    deadline: utcDateTime;
    createdAt: utcDateTime;
    updatedAt: utcDateTime;
  }

  model Project {
    @visibility(Lifecycle.Read, Lifecycle.Update)
    id: string;

    name: string;
    description: string;
    tasks: Task[];
    createdAt: utcDateTime;
    updatedAt: utcDateTime;
  }
}

namespace Errors {
  @error
  model BadRequest {
    code: 1;
    type: "BadRequest";
    message: string;
    errors: string[];
  }

  @error
  model Unauthorized {
    code: 2;
    type: "Unauthorized";
    message: string;
    errors: string[];
  }

  @error
  model Forbidden {
    code: 3;
    type: "Forbidden";
    message: string;
    errors: string[];
  }

  @error
  model NotFound {
    code: 4;
    type: "NotFound";
    message: string;
    errors: string[];
  }

  @error
  model InternalServerError {
    code: 5;
    type: "InternalServerError";
    message: string;
    errors: string[];
  }

  @error
  model TooManyRequests {
    code: 6;
    type: "TooManyRequests";
    message: string;
    errors: string[];
  }

  @error
  model ServiseMaintenance {
    code: 7;
    type: "ServiseMaintenance";
    message: string;
    errors: string[];
  }
}
