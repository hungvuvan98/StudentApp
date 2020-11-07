import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class StudentService {

  constructor(private http:HttpClient) { }

  GetInfo(id):Observable<any[]>{
    var url = environment.apiUrl + '/student/info/' + id
    return this.http.get<any[]>(url)
  }

  GetDepartment(id):Observable<string>{
    var url= environment.apiUrl +'/department/getbyid/'+id
    return this.http.get<string>(url)
  }

  GetStudentClass(id):Observable<string>{
    var url= environment.apiUrl +'/studentclass/GetClassNameByStudent'
    var params= new HttpParams().set('studentId',id)
    return this.http.get<string>(url,{params})
  }

  GetResultLearning(id): Observable<any[]>{
    var url= environment.apiUrl + '/student/result/' + id
    return this.http.get<any[]>(url)
  }


  GetListStudent(studentId):Observable<any[]>{
    var url =environment.apiUrl + '/studentclass/GetListStudent/'+ studentId
    return this.http.get<any[]>(url)
  }

  GetLevel(studentId):Observable<number>{
    var url=environment.apiUrl +'/warning/GetLevel'
    const params=new HttpParams().set('studentId',studentId)
    return this.http.get<number>(url,{params})
}
  
}
