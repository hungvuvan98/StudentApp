import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

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
