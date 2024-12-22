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
@server("http://localhost:8080", "Single server endpoint")
@versioned(SmartTask.Versions)
namespace SmartTask;

enum Versions {
  v1: "1.0.0",
}

@route("/v1")
namespace EndPoints {
  @tag("Tag")
  @route("/tags")
  namespace Tags {
    @get
    op list(
      ...Requests.QueryParameters.ListQuery,
      ...Requests.QueryParameters.SortQuery,
    ): Responses.GetResposne<Models.Tag[]>;

    @get
    op get(@path id: string): Responses.GetResposne<Models.Tag>;

    @post
    op create(
      @body request: Requests.Tag.Create,
    ): Responses.CreateResposne<Models.Tag>;

    @put
    op update(
      @path id: string,
      @body request: Requests.Tag.Update,
    ): Responses.UpdateResposne<Models.Tag>;

    @delete
    op delete(@path id: string): Responses.DeleteResposne<Models.Tag>;
  }

  @tag("Task")
  @route("/tasks")
  namespace Tasks {
    @get
    op list(
      ...Requests.QueryParameters.ListQuery,
      ...Requests.QueryParameters.SortQuery,
    ): Responses.GetResposne<Models.Task[]>;

    @get
    op get(@path id: string): Responses.GetResposne<Models.Task>;

    @post
    op create(
      @body request: Requests.Task.Create,
    ): Responses.CreateResposne<Models.Task>;

    @put
    op update(
      @path id: string,
      @body request: Requests.Task.Update,
    ): Responses.UpdateResposne<Models.Task>;

    @delete
    op delete(@path id: string): Responses.DeleteResposne<Models.Task>;
  }

  @tag("Project")
  @route("/projects")
  namespace Projects {
    @get
    op list(
      ...Requests.QueryParameters.ListQuery,
      ...Requests.QueryParameters.SortQuery,
    ): Responses.GetResposne<Models.Project[]>;

    @get
    op get(@path id: string): Responses.GetResposne<Models.Project>;

    @post
    op create(
      @body request: Requests.Project.Create,
    ): Responses.CreateResposne<Models.Project>;

    @put
    op update(
      @path id: string,
      @body request: Requests.Project.Update,
    ): Responses.UpdateResposne<Models.Project>;

    @delete
    op delete(@path id: string): Responses.DeleteResposne<Models.Project>;

    @tag("TaskInProject")
    @route("/{projectId}/tasks")
    namespace Tasks {
      @get
      op list(
        @path projectId: string,
        ...Requests.QueryParameters.ListQuery,
        ...Requests.QueryParameters.SortQuery,
      ): Responses.GetResposne<Models.Task[]>;

      @get
      op get(
        @path projectId: string,
        @path id: string,
      ): Responses.GetResposne<Models.Task>;

      @delete
      op delete(
        @path projectId: string,
        @path id: string,
      ): Responses.DeleteResposne<Models.Task>;
    }
  }
}

namespace Models {
  model Tag {
    id: string;
    name: string;
    color: int32;
    createdAt: utcDateTime;
    updatedAt: utcDateTime;
  }

  enum Status {
    Inbox: "Inbox",
    NextAction: "NextAction",
    Waiting: "Waiting",
    Done: "Done",
  }

  enum Priority {
    Low: "Low",
    Medium: "Medium",
    High: "High",
  }

  model Task {
    id: string;
    projectId?: string;
    title: string;
    description: string;
    status: Status;
    priority: Priority;
    tags: Tag[];
    deadline?: utcDateTime;
    createdAt: utcDateTime;
    updatedAt: utcDateTime;
  }

  model Project {
    id: string;
    name: string;
    description: string;
    tasks: Task[];
    createdAt: utcDateTime;
    updatedAt: utcDateTime;
  }
}

namespace Requests {
  namespace Tag {
    model Create {
      name: string;
      color?: int32;
    }
    model Update {
      id: string;
      name?: string;
      color?: int32;
    }
  }
  namespace Task {
    model Create {
      title: string;
      description: string;
      status: Models.Status;
      priority: Models.Priority;
      tags: Models.Tag[];
      deadline?: utcDateTime;
    }
    model Update {
      id: string;
      projectId?: string;
      title?: string;
      description?: string;
      status?: Models.Status;
      priority?: Models.Priority;
      tags?: Models.Tag[];
      deadline?: utcDateTime;
    }
  }
  namespace Project {
    model Create {
      name: string;
      description: string;
    }
    model Update {
      id: string;
      name?: string;
      description?: string;
    }
  }
  namespace QueryParameters {
    model ListQuery {
      @query
      limit?: int32;

      @query
      offset?: int32;
    }
    model SortQuery {
      @query
      sort?: string;
    }
  }
}

namespace Responses {
  alias GetResposne<T> = Models.OkResposne<T> | Models.ErrorReponses;
  alias CreateResposne<T> = Models.CreateResposne<T> | Models.ErrorReponses;
  alias UpdateResposne<T> = Models.OkResposne<T> | Models.ErrorReponses;
  alias DeleteResposne<T> = Models.OkResposne<T> | Models.ErrorReponses;
  namespace Models {
    // Success
    model OkResposne<T> {
      ...TypeSpec.Http.OkResponse;
      ...Body<T>;
    }
    model CreateResposne<T> {
      ...TypeSpec.Http.CreatedResponse;
      ...Body<T>;
    }

    // Error
    enum ErrorCode {
      BadRequest: 1,
      Unauthorized: 2,
      Forbidden: 3,
      NotFound: 4,
      InternalServerError: 5,
      TooManyRequests: 6,
      NotDeletableResource: 7,
      ServiseMaintenance: 8,
    }
    enum ErrorType {
      BadRequest: "BadRequest",
      Unauthorized: "Unauthorized",
      Forbidden: "Forbidden",
      NotFound: "NotFound",
      InternalServerError: "InternalServerError",
      TooManyRequests: "TooManyRequests",
      NotDeletableResource: "NotDeletableResource",
      ServiseMaintenance: "ServiseMaintenance",
    }

    model ErrorResponse<Code extends ErrorCode, Type extends ErrorType> {
      code: Code;
      type: Type;
      message: string;
      errors: string[];
    }

    @error
    model BadRequestResposne {
      ...TypeSpec.Http.BadRequestResponse;
      ...ErrorResponse<ErrorCode.BadRequest, ErrorType.BadRequest>;
    }

    @error
    model UnauthorizedResposne {
      ...TypeSpec.Http.UnauthorizedResponse;
      ...ErrorResponse<ErrorCode.Unauthorized, ErrorType.Unauthorized>;
    }

    @error
    model ForbiddenResposne {
      ...TypeSpec.Http.ForbiddenResponse;
      ...ErrorResponse<ErrorCode.Forbidden, ErrorType.Forbidden>;
    }

    @error
    model NotFoundResposne {
      ...TypeSpec.Http.NotFoundResponse;
      ...ErrorResponse<ErrorCode.NotFound, ErrorType.NotFound>;
    }

    @error
    model InternalServerErrorResponse {
      @statusCode statusCode: 500;
      ...ErrorResponse<
        ErrorCode.InternalServerError,
        ErrorType.InternalServerError
      >;
    }

    @error
    model TooManyRequestsResponse {
      @statusCode statusCode: 429;
      ...ErrorResponse<ErrorCode.TooManyRequests, ErrorType.TooManyRequests>;
    }

    @error
    model NotDeletableResource {
      ...TypeSpec.Http.BadRequestResponse;
      ...ErrorResponse<
        ErrorCode.NotDeletableResource,
        ErrorType.NotDeletableResource
      >;
    }

    @error
    model ServiseMaintenance {
      @statusCode statusCode: 503;
      ...ErrorResponse<
        ErrorCode.ServiseMaintenance,
        ErrorType.ServiseMaintenance
      >;
    }

    alias ErrorReponses =
      | BadRequestResposne
      | UnauthorizedResposne
      | ForbiddenResposne
      | NotFoundResposne
      | InternalServerErrorResponse
      | TooManyRequestsResponse
      | NotDeletableResource
      | ServiseMaintenance;
  }
}
