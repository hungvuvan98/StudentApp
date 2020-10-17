import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ListClass } from '../models/list-class';
import { environment } from '../../../../environments/environment';

@Injectable()
export class ListClassService {

constructor(private http: HttpClient) { }

GetAll(semester:string):Observable<ListClass[]>{
    var url= environment.apiUrl + '/class/getall'
    var params= new HttpParams().set('semester',semester)
    return this.http.get<ListClass[]>(url,{params})   
}
}
