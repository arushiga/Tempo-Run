import CoreTransferable
import UniformTypeIdentifiers

enum PlannerDragItem: Codable, Transferable {
    case runType(RunType)
    case scheduledRun(ScheduledRun)

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .tempoPlannerDragItem)
    }
}

extension UTType {
    static let tempoPlannerDragItem = UTType(exportedAs: "com.tempo.planner-drag-item")
}
