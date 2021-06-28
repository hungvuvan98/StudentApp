import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';
@Injectable({
  providedIn: 'root'
})
export class StudentFeeService {

  constructor(private http:HttpClient) { }

  GetFees(studentId):Observable<any[]>{
    var url = environment.apiUrl + '/StudentFee/'+studentId;
    return this.http.get<any[]>(url)
  }
}
