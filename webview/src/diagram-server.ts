import { injectable } from "inversify";
import { ActionHandlerRegistry } from "sprotty";
import { Action, isAction } from 'sprotty-protocol';
import { VscodeLspEditDiagramServer } from "sprotty-vscode-webview/lib/lsp/editing";
import { AddAttributeAction, ChangeNotationAction, CreateElementEditAction } from "./actions";

@injectable()
export class BigERDiagramServer extends VscodeLspEditDiagramServer {

    override initialize(registry: ActionHandlerRegistry): void {
        super.initialize(registry);
        registry.register(ChangeNotationAction.KIND, this);
        registry.register(CreateElementEditAction.KIND, this);
        registry.register(AddAttributeAction.KIND, this);
    }

    /**
     * Check which actions should be handled on the server by returning true. If false,
     * the action is handled locally (slightly counter-intuitive with the method's name).
     */
    override handleLocally(action: Action): boolean {
        if (isAction(ChangeNotationAction.KIND)) {
            return true;
        } else if (isAction(CreateElementEditAction.KIND)) {
            return true;
        } else if (isAction(AddAttributeAction.KIND)) {
            return true;
        } else {
            return super.handleLocally(action);
        }
    }
}