import 'package:super_editor/super_editor.dart';

class InsertPlugin extends SuperEditorPlugin {
  const InsertPlugin();

  //   _requestHandlers = <EditRequestHandler>[
  //   (request) => request is FillInComposingStableTagRequest
  //       ? FillInComposingUserTagCommand(request.tag, request.tagRule)
  //       : null,
  //   (request) => request is CancelComposingStableTagRequest //
  //       ? CancelComposingStableTagCommand(request.tagRule)
  //       : null,
  // ];

  // _reactions = [
  //   TagUserReaction(
  //     tagRule: tagRule,
  //     onUpdateComposingStableTag: tagIndex._onComposingStableTagFound,
  //   ),
  //   AdjustSelectionAroundTagReaction(tagRule),
  // ];

  @override
  void attach(Editor editor) {}
  @override
  void detach(Editor editor) {}
}

class InsertUserReaction extends EditReaction {
  @override
  void react(
    EditContext editorContext,
    RequestDispatcher requestDispatcher,
    List<EditEvent> changeList,
  ) {
    super.react(editorContext, requestDispatcher, changeList);
  }
}
