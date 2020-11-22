import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';

@Injectable()
export class ClassListService {

constructor(private http:HttpClient) { }
GetAll(semester:string):Observable<any[]>{
    var url= environment.apiUrl + '/class/getall'
    var params = new HttpParams().set('semester', semester)
    return this.http.get<any[]>(url,{params})   
}

}
