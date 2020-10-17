import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import {environment} from '../../../../environments/environment';

@Injectable()
export class WarningService {

constructor(private http:HttpClient) { }

GetLevel(studentId):Observable<number>{
    var url=environment.apiUrl +'/warning/GetLevel'
    const params=new HttpParams().set('studentId',studentId)
    return this.http.get<number>(url,{params})
}

}
