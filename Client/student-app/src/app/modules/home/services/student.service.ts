import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import {StudentInfo} from '../models/studentinfo';
import {environment} from '../../../../environments/environment';
import { Router } from '@angular/router';
import { ResultLearning } from '../../admin/models/student/resultlearning';
@Injectable()
export class StudentService {

constructor(private http:HttpClient,private route:Router) { }

    GetInfo(id):Observable<StudentInfo>{
        var url = environment.apiUrl + '/student/info/' + id;
        return this.http.get<StudentInfo>(url)
    }
   
    Logout(){
        localStorage.clear()
        this.route.navigate([''])
    }

    SendRegister(data):Observable<number[]>{
        var url = environment.apiUrl + '/Student/SendRegister'
       return this.http.post<number[]>(url,data)
    }

    GetResultLearning(id): Observable<ResultLearning[]>{
        var url= environment.apiUrl + '/student/result/' + id
        return this.http.get<ResultLearning[]>(url)
      }
    
}
