import {Injectable} from '@angular/core';
import {Observable} from 'rxjs';
import { Student } from '../../../../modules/admin/models/student/student';
import { environment } from '../../../../../environments/environment';
import { HttpClient, HttpParams } from '@angular/common/http';
import { StudentDetail } from '../../../../modules/admin/models/student/student-detail';
import { ResultLearning } from '../../../../modules/admin/models/student/resultlearning';
import { CreateStudentModel } from '../../../../modules/admin/models/student/createstudentmodel';


@Injectable({providedIn: 'root'})

export class StudentService {

  constructor(private http: HttpClient) {

  }

  // code of Student page
  GetStudent():Observable<Student[]>{

    var url = environment.apiUrl + '/student/getall';
    return this.http.get<Student[]>(url);
  }

  GetDetail(id):Observable<StudentDetail[]>{
    var url = environment.apiUrl + '/student/getscore/';
    return this.http.get<StudentDetail[]>(url + id);
  }

  DeleteStudent(id):Observable<any>{
    var url = environment.apiUrl + '/student/delete/'
    var params= new HttpParams().set('id',id)
    return this.http.delete<any>(url,{params});
  }
  
  FilterStudent(year?,dept?,className?):Observable<Student[]>{
    var url = environment.apiUrl + '/student/filter'
    year=year.trim()
    dept=dept.trim()
    className=className.trim()
    const params = new HttpParams()
                    .set('Year', year)
                    .set('Dept', dept)
                    .set('ClassName',className);
    return this.http.get<Student[]>(url,{params})
  }

  GetClassName(year:string,dept_name:string): Observable<string[]> {
    year = year.trim();
    dept_name = dept_name.trim();
    var url= environment.apiUrl + '/StudentClass/getclassname'
    const options = year ?
     { params: new HttpParams().set('year', year).set('dept_name',dept_name) } : {}
     
    return this.http.get<string[]>(url, options)
     
  }

  // code of Student detail

  GetResultLearning(id): Observable<ResultLearning[]>{

    var url= environment.apiUrl + '/student/result/' + id
    return this.http.get<ResultLearning[]>(url)
  }

  // code of add new student
  
  GetDepartment(): Observable<string[]>{
    var url = environment.apiUrl + '/department/getname';
    return this.http.get<string[]>(url)
  }
  
  AddStudent(data):Observable<CreateStudentModel>{
    var url = environment.apiUrl + '/student/create';
    return this.http.post<CreateStudentModel>(url,data)
  }

  //code home module
}