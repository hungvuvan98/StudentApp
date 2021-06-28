import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class SearchStudentByClassService {

  constructor(private http:HttpClient) { }

  // GetStudents(studentClassId):Observable<any[]>{
  //   var url = environment.apiUrl + '/StudentClass/'+studentClassId;
  //   return this.http.get<any[]>(url)
  // }
}
