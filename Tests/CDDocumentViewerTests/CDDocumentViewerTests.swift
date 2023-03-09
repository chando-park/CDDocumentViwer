import XCTest
@testable import CDDocumentViewer

final class CDDocumentViewerTests: XCTestCase {
    
    let vc = UIViewController()
    var documentViwer: CDDocumentViewer?
    
    override func setUpWithError() throws {
        
        self.documentViwer = CDDocumentViewer(presenter: vc)
    }
    
    override func tearDownWithError() throws {
        self.documentViwer = nil
    }
    
    func testExample() throws {
        
        let ex = self.expectation(description: "document view test")
        
        self.documentViwer?.setStatusCloser { status in
            switch status{
            case .end(let isSuccess, let errorMessage):
                ex.fulfill()
                XCTAssertTrue(isSuccess, errorMessage ?? "")
                break
            default:
                break
            }
        }
        
        self.documentViwer?.opnePDF(urlStr: "https://cdn.littlefox.co.kr/contents/class/pbook/Writing_Starter_3_CLASS.pdf", title: "")
        
        wait(for: [ex], timeout: 4)
        
    }
}
