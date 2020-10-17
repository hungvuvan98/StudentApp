import { Injectable } from '@angular/core';
import { environment } from '../../../environments/environment';
import { HttpParams, HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';


@Injectable()
export class MainService {

 constructor(private http:HttpClient) { }

  getNewestSemester():Observable<string>{
    var url= environment.apiUrl + '/semester/GetNewest'
    return this.http.get<string>(url)
  }
 
  setSemester(semester):Observable<number>{
      var url= environment.apiUrl + '/semester/insert'
      var params= new HttpParams().set('id',semester)
     return this.http.get<number>(url,{params})
  }
}
