import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { CreateClass } from '../models/Class/create-class';
import { environment } from '../../../../environments/environment';

@Injectable()
export class ClassListService {

constructor(private http: HttpClient) { }

GetAll(semester:string):Observable<CreateClass[]>{
    var url= environment.apiUrl + '/class/getall'
    var params= new HttpParams().set('semester',semester)
    return this.http.get<CreateClass[]>(url,{params})   
}

}
