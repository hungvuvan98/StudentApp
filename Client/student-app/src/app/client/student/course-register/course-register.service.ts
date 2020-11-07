import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';

@Injectable()
export class CourseRegisterService {

    constructor(private http: HttpClient) { }

    GetClassNameByStudent(studentId):Observable<any>{
        var url= environment.apiUrl + '/StudentClass/GetClassNameByStudent' 
        var params= new HttpParams().set('studentId',studentId)
        return this.http.get<any>(url,{params})
    }
   
    GetRegisteredClassByStudentId(semester,studentId?):Observable<any[]>{
        var url= environment.apiUrl + '/Class/GetRegisteredClassByStudentId'
        var params= new HttpParams().set('studentId',studentId)
                                    .set('semester',semester)
        return this.http.get<any[]>(url,{params})
    }

    RegisterClassTemp(classId,semester):Observable<any>{
        var url= environment.apiUrl + '/class/GetClassBySecId'
        var params= new HttpParams().set('secId',classId)
                                    .set('semester',semester)
        return this.http.get<any>(url,{params})
    }

    SendRegister(data):Observable<number[]>{
        var url = environment.apiUrl + '/Student/SendRegister'
       return this.http.post<number[]>(url,data)
    }

}
