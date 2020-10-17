import { Injectable } from '@angular/core';
import { environment } from '../../../../environments/environment';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  private loginPath = environment.apiUrl + '/account/login';

  constructor(private http: HttpClient) { }

  login(data): Observable<any> {
   return this.http.post(this.loginPath,data);
  }

  saveToken(token){
    localStorage.setItem('token',token);
  }
  saveStudentId(id){
    localStorage.setItem('studentId',id)
  }
  getStudentId(){
    return localStorage.getItem('studentId');
  }
  getToken(){
    return localStorage.getItem('token');
  }

  isAuthenticated(){
    if(this.getToken()){
      return true;
    }
    return false;
  }
}
