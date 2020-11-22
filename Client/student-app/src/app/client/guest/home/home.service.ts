import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import {environment} from '../../../../environments/environment'
@Injectable()
export class HomeService {

  constructor(private http: HttpClient) { }
  
  getPostByCategory(categoryId): Observable<any[]>{
    const url = environment.apiUrl + '/post/GetByCategory/'+ categoryId;
    return this.http.get<any[]>(url);
  }

}
