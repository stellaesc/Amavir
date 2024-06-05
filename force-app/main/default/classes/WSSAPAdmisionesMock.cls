/**
@description
<pre>
Clase Mock para testear la llamada a su servicio de Admisiones en SAP
</br>
FECHA       AUTOR   	DESCRIPCION<br/>
06/09/2021	LCS MMV		Created	    
</pre>
@author Leadclic Solutions
@date 25/01/2021
*/
global class WSSAPAdmisionesMock implements HttpCalloutMock {

    String payload;

    public WSSAPAdmisionesMock(String payload) {
        this.payload = payload;
    }

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(payload);
        res.setStatusCode(200);
        return res;
    }
}