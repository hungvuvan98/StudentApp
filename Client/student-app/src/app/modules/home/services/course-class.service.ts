import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import {environment} from '../../../../environments/environment';
import { ListClass } from '../models/list-class';

@Injectable()
export class CourseClassService {

    constructor(private http: HttpClient) { }

    GetClassNameByStudent(studentId):Observable<any>{
        var url= environment.apiUrl + '/StudentClass/GetClassNameByStudent' 
        var params= new HttpParams().set('studentId',studentId)
        return this.http.get<any>(url,{params})
    }
   
    GetRegisteredClassByStudentId(semester,studentId?):Observable<ListClass[]>{
        var url= environment.apiUrl + '/Class/GetRegisteredClassByStudentId'
        var params= new HttpParams().set('studentId',studentId)
                                    .set('semester',semester)
        return this.http.get<ListClass[]>(url,{params})
    }

    RegisterClassTemp(classId,semester):Observable<ListClass>{
        var url= environment.apiUrl + '/class/GetClassBySecId'
        var params= new HttpParams().set('secId',classId)
                                    .set('semester',semester)
        return this.http.get<ListClass>(url,{params})
    }

}
