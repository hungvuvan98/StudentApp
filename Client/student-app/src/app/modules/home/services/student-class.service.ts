import { Injectable } from '@angular/core';
import {environment} from '../../../../environments/environment'
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable()
export class StudentClassService {

constructor(private http:HttpClient) { }

GetById(id):Observable<string>{
    var url= environment.apiUrl +'/studentclass/GetClassNameByStudent'
    var params= new HttpParams().set('studentId',id)
    return this.http.get<string>(url,{params})
}
}
