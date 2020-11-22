import { HttpClient, HttpParams, HttpResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';

@Injectable()
export class CourseRegisterService {

    constructor(private http: HttpClient) { }

    GetClassNameByStudent(studentId):Observable<any>{
        const url = environment.apiUrl + '/StudentClass/GetClassNameByStudent' 
        var params= new HttpParams().set('studentId',studentId)
        return this.http.get(url,{params,responseType:'text'})
    }
   
    GetRegisteredClassByStudentId(semester,studentId?):Observable<any[]>{
        const url= environment.apiUrl + '/Class/GetRegisteredClassByStudentId'
        var params= new HttpParams().set('studentId',studentId)
                                    .set('semester',semester)
        return this.http.get<any[]>(url,{params})
    }

    RegisterClassTemp(classId,semester):Observable<any>{
        const url= environment.apiUrl + '/class/GetClassBySecId'
        var params= new HttpParams().set('secId',classId)
                                    .set('semester',semester)
        return this.http.get(url, { params })
        // response to log any properties       
    }

    SendRegister(data):Observable<number[]>{
        const url = environment.apiUrl + '/Student/SendRegister'
       return this.http.post<number[]>(url,data)
    }

    CheckDuplicateTime(listClass): Observable<any>{
        const url = environment.apiUrl + '/Class/CheckDuplicateTime'
        return this.http.post<any>(url, listClass)
                       
    }

}
