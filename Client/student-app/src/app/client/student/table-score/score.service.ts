import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';

@Injectable()
export class ScoreService {

constructor(private http:HttpClient) { }

GetDetail(id):Observable<any[]>{
  var url = environment.apiUrl + '/student/getscore/';
  return this.http.get<any[]>(url + id);
}

GetResultLearning(id): Observable<any[]>{

  var url= environment.apiUrl + '/student/result/' + id
  return this.http.get<any[]>(url)
}
  
}
