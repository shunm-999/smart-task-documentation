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

@route("/tags")
namespace Tags {
  @get
  op listTags(): {
    @statusCode statusCode: 200;
    @body tags: Tag[];
  };

  @get
  op getTag(@path id: string): {
    @statusCode statusCode: 200;
    @body tag: Tag;
  };

  @post
  op createTag(@path id: string, @body tag: Tag): {
    @statusCode statusCode: 201;
    @body tag: Tag;
  };

  @put
  op updateTag(@path id: string, @body tag: Tag): {
    @statusCode statusCode: 200;
    @body tag: Tag;
  };

  @delete
  op deleteTag(@path id: string): {
    @statusCode statusCode: 204;
  };
}

enum Versions {
  v1: "1.0",
}

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
