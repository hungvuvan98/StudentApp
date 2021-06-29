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
    return this.http.get(url,{responseType:'text'})
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

  GetLevel():Observable<number>{
    var url=environment.apiUrl +'/toeic/CheckConditionToRegister'
    return this.http.get<number>(url)
  }




  // code of Student page
  GetStudents():Observable<any[]>{

    var url = environment.apiUrl + '/student/getall';
    return this.http.get<any[]>(url);
  }

  GetDetail(id):Observable<any[]>{
    var url = environment.apiUrl + '/student/getscore/';
    return this.http.get<any[]>(url + id);
  }

  DeleteStudent(id):Observable<any>{
    var url = environment.apiUrl + '/student/delete/'
    var params= new HttpParams().set('id',id)
    return this.http.delete<any>(url,{params});
  }

  FilterStudent(year?,dept?,className?):Observable<any[]>{
    var url = environment.apiUrl + '/student/filter'
    year=year.trim()
    dept=dept.trim()
    className=className.trim()
    const params = new HttpParams()
                    .set('Year', year)
                    .set('Dept', dept)
                    .set('ClassName',className);
    return this.http.get<any[]>(url,{params})
  }

  GetClassName(year:string,dept_name:string): Observable<string[]> {
    year = year.trim();
    dept_name = dept_name.trim();
    var url= environment.apiUrl + '/StudentClass/getclassname'
    const options = year ?
     { params: new HttpParams().set('year', year).set('dept_name',dept_name) } : {}

    return this.http.get<string[]>(url, options)

  }

  getStudentClasses(year,departmentId):Observable<any[]>{
    var url= environment.apiUrl + `/StudentClass/${year}/${departmentId}`;
    return this.http.get<any[]>(url);
  }

  getStudentsByClassAndDepartment(departmentId, classId):Observable<any[]>{
    var url=environment.apiUrl+`/student/${departmentId}/${classId}`;
    return this.http.get<any[]>(url);
  }
}
