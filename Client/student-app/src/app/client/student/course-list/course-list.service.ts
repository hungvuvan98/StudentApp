import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';
@Injectable({
  providedIn: 'root'
})
export class CourseListService {

  constructor(private http:HttpClient) { }

  GetDepartments():Observable<any[]>{
    var url= environment.apiUrl+'/Department'
    return this.http.get<any[]>(url);
  }

  GetCourse(departmentId:string):Observable<any>{
    var url= environment.apiUrl+'/course/'+departmentId;
    return this.http.get<any[]>(url);
  }
}
