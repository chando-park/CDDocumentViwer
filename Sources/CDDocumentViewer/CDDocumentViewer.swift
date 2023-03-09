
import UIKit

public class DocumentDownload: NSObject{
    
    enum LoadStatus{
        case start
        case ing
        case end(isSuccess: Bool, errorMessage: String?)
    }
    typealias DocumentDownloadStatusCloser = (LoadStatus)->()
    
    
    deinit{
        print("deinit \(self)")
    }
    
    var canOpenPDF: Bool = true
    
    unowned private let _presenter: UIViewController
    private var _statusCloser: DocumentDownloadStatusCloser?
    private let _documentInteractionController: UIDocumentInteractionController
    private var _task: URLSessionDataTask?
    
    init(presenter: UIViewController, statusCloser: DocumentDownloadStatusCloser? = nil) {
        self._presenter = presenter
        self._statusCloser = statusCloser
        self._documentInteractionController = UIDocumentInteractionController()
        
        super.init()
        
        self._documentInteractionController.delegate = self
    }
    
    func opnePDF(urlStr: String?, title: String){
        
        guard self.canOpenPDF else {
            return
        }
        
        if let s = urlStr{
            if #available(iOS 10.0, *) {
//                self.canOpenPDF = false
                self.storeAndShare(withURLString: s, title: title)
            } else {
                UIApplication.shared.openURL(URL(string: s)!)
            }
        }else{
            print("pdf url incorrected")
        }
    }
    
    
    private func share(url: URL, title: String) {
        self._documentInteractionController.url = url
        self._documentInteractionController.uti = (try? url.resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier ?? "public.data, public.content"
        self._documentInteractionController.name = title
        self._documentInteractionController.presentPreview(animated: true)
    }
    
    
    /// This function will store your document to some temporary URL and then provide sharing, copying, printing, saving options to the user
    private func storeAndShare(withURLString: String, title: String) {
        self._statusCloser?(.start)
        guard let url = URL(string: withURLString) else {
            self._statusCloser?(.end(isSuccess: false, errorMessage: "invalid url address"))
            return
        }
        
        self.cancel()
        
        self._task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            self._statusCloser?(.ing)
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self._statusCloser?(.end(isSuccess: false, errorMessage: error?.localizedDescription))
                }
                return
            }
            
            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(response?.suggestedFilename ?? "fileName.png")
            do {
                try data.write(to: tmpURL)
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self._statusCloser?(.end(isSuccess: false, errorMessage: error.localizedDescription))
                }
            }
            DispatchQueue.main.async {
                self.share(url: tmpURL, title: title)
                self._statusCloser?(.end(isSuccess: true, errorMessage: nil))
            }
        }//.resume()
        self._task?.resume()
    }
    
    func cancel(){
        self._task?.cancel()
        self._task = nil
    }
}

extension DocumentDownload: UIDocumentInteractionControllerDelegate {
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        self._presenter
    }
}
